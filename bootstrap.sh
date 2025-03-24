#! /usr/bin/env bash
# This file should be used when installing NixOS onto a remote machine using nixos-anywhere
#
# PROBLEM:
# The problem is that we need to have a prober secret management system. And when we rebuild
# on an exisiting host, this isn't a problem since that host already have some valid ssh host key
# or a user age key for decrypting the secrets.
# But when we are installing to a fresh system (ex. NixOS Installer ISO), that system doesn't
# have any valid ssh host key nor any valid user age key. So we need some way registering
# new valid keys for this target and sending them over before nixos-anywhere is run.
#
# SOLUTION:
# * After following the prerequisits, we run this script, and it will:
# * Get the public ssh host key from the secrets you just added, and convert it into a age key with ssh-to-age
# * Then it will add the ssh-derived public age key to the list of valid hosts age keys in $SOPS_FILE
# * Then it will generate a new age key for the primary user ($target_user)
# * It will add the public age key to the list of valid user age keys
# * Then it will add the private user age key to the secrets, so that later when we run nixos-anywhere, the
#   configuration can extract this private user age key to ~/.config/sops/age/key.txt. This is so that
#   the $target_user can also decrypt the secrets (ex. when running `nixos-rebuild` etc.).
# * Then it will copy the host ssh key pair to the target with SCP (so it can decrypt during the installation)
# * Finally when a valid key has been moved to the target machine, we run nixos-anywhere
#
# PREREQUISITS:
# * Create a SSH host keypair for the remote target:
#   $ ssh-keygen -t ed25519 -C root@<hostname>
# * Create a secrets file intended to store secrets for the new host:
#   $ sops secrets/<hostname>.yaml
# * The secrets file must contain the following:
#   - host-key: <private_ssh_host_key> # The one generated just above
# * git add the secrets file so nix can find it
# * Make sure to clean up temporary files like the generated ssh keypair. Just `rm` them
#
# NOTES:
# * Before rebuilding the target machine, you need to git push the changes this script makes
#   to the secrets and sops config file. Otherwise the target machine will have a version where their
#   keys aren't valid.
# * We need to SSH into the target as root, so you have to set a password for the root account.
#   If you use a NixOS ISO, you can type:
#   $ sudo passwd root
#   And just set it to "1" or something temporary
# 
# EXAMPLES:
# $ ./bootstrap.sh -n <hostname> -d <ip> -u <primary_user> --ssh-user root --host <flake_host>
#
# $ ./bootstrap.sh -n waltherbox -d 192.168.100.210 -u walther --ssh-user root --host waltherbox-vm
set -euo pipefail

SOPS_FILE=".sops.yaml"
SOPS_SECRETS_DIR="secrets"
SOPS_SECRETS_SHARED="$SOPS_SECRETS_DIR/shared.yaml"
SCP_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

# UTILITIES
function red() {
	echo -e "\x1B[31m[!] $1 \x1B[0m"
	if [ -n "${2-}" ]; then
		echo -e "\x1B[31m[!] $($2) \x1B[0m"
	fi
}

function green() {
	echo -e "\x1B[32m[+] $1 \x1B[0m"
	if [ -n "${2-}" ]; then
		echo -e "\x1B[32m[+] $($2) \x1B[0m"
	fi
}

function blue() {
	echo -e "\x1B[34m[*] $1 \x1B[0m"
	if [ -n "${2-}" ]; then
		echo -e "\x1B[34m[*] $($2) \x1B[0m"
	fi
}

function yellow() {
	echo -e "\x1B[33m[*] $1 \x1B[0m"
	if [ -n "${2-}" ]; then
		echo -e "\x1B[33m[*] $($2) \x1B[0m"
	fi
}

# Updates the .sops.yaml file with a new host or user age key.
function sops_update_age_key() {
	field="$1"
	keyname="$2"
	key="$3"

    arr_idx=0
    if [ "$field" == "hosts" ]; then
        arr_idx=1
    else
        arr_idx=0
    fi

	if [ ! "$field" == "hosts" ] && [ ! "$field" == "users" ]; then
		red "Invalid field passed to sops_update_age_key. Must be either 'hosts' or 'users'."
		exit 1
	fi

    if [[ -n $(yq ".keys[$arr_idx].$field" "$SOPS_FILE" | grep "$keyname") ]]; then
		green "Updating existing ${keyname} key"
        yq -i "(.keys[$arr_idx].$field | .[] | select(anchor == \"$keyname\")) = \"$key\"" "$SOPS_FILE"
	else
		green "Adding new ${keyname} key"
        yq -i ".keys[$arr_idx].$field += [\"&$keyname $key\"]" "$SOPS_FILE"
        sed -i "s/'\&$keyname $key'/\&$keyname $key/" "$SOPS_FILE"
	fi
}

function sops_add_to_keygroup() {
    keyname="$1"

    green "Adding $keyname as valid key to key_group"
    if [[ ! -n $(yq '.creation_rules.[].key_groups.[].age | .[]' "$SOPS_FILE" | grep -w "$keyname") ]]; then
        yq -i ".creation_rules.[].key_groups.[].age += [\"*$keyname\"]" "$SOPS_FILE"
        sed -i "s/'\*$keyname'/\*$keyname/" "$SOPS_FILE"
    else
        yellow "key_group already contains $keyname"
    fi
}

target_hostname=""
target_destination=""
target_user=""
ssh_user=""
flake_host=""
ssh_port=22

# MAIN PROGRAM
# Handle command-line arguments
while [[ $# -gt 0 ]]; do
	case "$1" in
	-n)
		shift
		target_hostname=$1
		;;
	-d)
		shift
		target_destination=$1
		;;
	-u)
		shift
		target_user=$1
		;;
	--ssh-user)
		shift
		ssh_user=$1
		;;
    --host)
        shift
        flake_host=$1
        ;;
	--port)
		shift
		ssh_port=$1
		;;
	--debug)
		set -x
		;;
	*)
		red "ERROR: Invalid option detected."
		;;
	esac
	shift
done

if [ -z "$target_hostname" ] || [ -z "$target_destination" ] || [ -z "$ssh_user" ] || [ -z "$flake_host" ] || [ -z "$target_user" ]; then
	red "ERROR: -n, -d, -u, --ssh-user,--host are required"
	echo
fi

temp_dir=$(mktemp -d)
trap "rm -rf $temp_dir" exit
mkdir -p $temp_dir/ssh

hostname_sops_secret_file="$SOPS_SECRETS_DIR/$target_hostname.yaml"

if [ ! -f "$hostname_sops_secret_file" ]; then
    red "No hostname secrets file! $hostname_sops_secret_file. Read pre-requisits for help"
    exit 1
fi

ssh_host_key=$(sops -d "$hostname_sops_secret_file" | yq ".host-key" -)

green "Getting public key from private key..."
echo "$ssh_host_key" > "$temp_dir/ssh/ssh_host_ed25519_key"
chmod u=rw,g=,o= $temp_dir/ssh/ssh_host_ed25519_key
ssh-keygen -y -f "$temp_dir/ssh/ssh_host_ed25519_key" > $temp_dir/ssh/ssh_host_ed25519_key.pub
public_ssh_key=$(cat $temp_dir/ssh/ssh_host_ed25519_key.pub)
echo "public ssh key: $public_ssh_key"

green "Converting public ssh host key to age key"
nix-shell -p ssh-to-age --run "cat $temp_dir/ssh/ssh_host_ed25519_key.pub | ssh-to-age > $temp_dir/age.txt"
age_key=$(cat $temp_dir/age.txt)
echo "public age key for $target_hostname: $age_key"

green "Adding host age key to $SOPS_FILE"
sops_update_age_key "hosts" "$target_hostname" "$age_key"

# TODO: if sops secrets already contains a age key for the user, just reuse that key
green "Generating age key specific for $target_user..."
mkdir -p $temp_dir/age
age-keygen -o $temp_dir/age/key.txt
private_user_age_key=$(grep "AGE-SECRET-KEY" $temp_dir/age/key.txt)
public_user_age_key=$(age-keygen -y $temp_dir/age/key.txt)
echo "Public age-key for $target_user: $public_user_age_key"

green "Adding user age key to $SOPS_FILE"
sops_update_age_key "users" "$target_user" "$public_user_age_key"

sops_add_to_keygroup "$target_hostname"
sops_add_to_keygroup "$target_user"

green "Adding private user age key to $hostname_sops_secret_file"
# Check if system already has a primary user age key
if [[ $(sops -d "$hostname_sops_secret_file" | yq ".keys") != "null" ]]; then
    yellow "$hostname_sops_secret_file already contains age key. Overwriting with new..."
    sops set "$hostname_sops_secret_file" "[\"keys\"]" "{\"age-key\": \"$private_user_age_key\"}"
else
    decrypted=$(sops -d "$hostname_sops_secret_file")
    decrypted+=$(echo -e "\nkeys:\n  age-key: ${private_user_age_key}")
    echo "${decrypted}" > $hostname_sops_secret_file
    # re-encrypt
    encrypted=$(sops encrypt "$hostname_sops_secret_file")
    echo "$encrypted" > "$hostname_sops_secret_file"
fi

green "Updaing keys to secrets"
for file in $(ls $SOPS_SECRETS_DIR/*.yaml); do
    sops updatekeys -y $file;
done

green "Copying ssh host keypair to target..."
scp -r -P $ssh_port $SCP_OPTS $temp_dir/ssh/* $ssh_user@$target_destination:/etc/ssh/

# TODO: --generate-hardware-config support
# TODO: extra flags custom flags
green "Running nixos-anywhere..."
sudo nix run github:nix-community/nixos-anywhere -- --target-host $ssh_user@$target_destination --flake .#$flake_host --copy-host-keys

