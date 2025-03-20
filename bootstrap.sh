#! /usr/bin/env bash
set -euo pipefail

SOPS_FILE=".sops.yaml"
SOPS_SECRETS="secrets.yaml";
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
mkdir -p $temp_dir/ssh

ssh_host_key=$(sops -d secrets.yaml | yq ".private_host_keys.${target_hostname}" -)

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

green "Adding private user age key to $SOPS_SECRETS"
sops set $SOPS_SECRETS "[\"keys\"][\"age\"]" "{\"$target_user\": \"$private_user_age_key\"}"

green "Updaing keys to secrets"
sops updatekeys --yes "$SOPS_SECRETS"

green "Copying ssh host keypair to target..."
scp -r -P $ssh_port $SCP_OPTS $temp_dir/ssh/* $ssh_user@$target_destination:/etc/ssh/

green "Running nixos-anywhere..."
sudo nix run github:nix-community/nixos-anywhere -- --target-host $ssh_user@$target_destination --flake .#$flake_host --copy-host-keys

