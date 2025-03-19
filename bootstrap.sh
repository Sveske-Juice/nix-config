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

	if [ ! "$field" == "hosts" ] && [ ! "$field" == "users" ]; then
		red "Invalid field passed to sops_update_age_key. Must be either 'hosts' or 'users'."
		exit 1
	fi

    if [[ -n $(yq ".keys[1].hosts | .[] | select(. == \"$key\")" "$SOPS_FILE") ]]; then
		green "Updating existing ${keyname} key"
        yq -i "(.keys[] | select(anchor == \"$field\") | .[] | select(anchor == \"$keyname\")) = \"$key\"" "$SOPS_FILE"
	else
		green "Adding new ${keyname} key"
        yq -i ".keys[1].hosts += [\"&$keyname $key\"]" "$SOPS_FILE"
        sed -i "s/'\&$keyname $key'/\&$keyname $key/" "$SOPS_FILE"
	fi
}

target_hostname=""
target_destination=""
target_user=""
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

if [ -z "$target_hostname" ] || [ -z "$target_destination" ] || [ -z "$target_user" ] || [ -z "$flake_host" ]; then
	red "ERROR: -n, -d, -u, --host are required"
	echo
fi

temp_dir=$(mktemp -d)
mkdir -p $temp_dir/ssh

ssh_host_key=$(sops -d secrets.yaml | yq ".private_host_keys.${target_hostname}" -)
echo "$ssh_host_key"

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

green "Adding age key to $SOPS_FILE"
sops_update_age_key "hosts" "$target_hostname" "$age_key"

green "Adding age key to key_group"
if [[ ! -n $(yq '.creation_rules.[].key_groups.[].age | .[]' .sops.yaml | grep "$target_hostname") ]]; then
    yq -i ".creation_rules.[].key_groups.[].age += [\"*$target_hostname\"]" "$SOPS_FILE"
    sed -i "s/'\*$target_hostname'/\*$target_hostname/" "$SOPS_FILE"
else
    yellow "key_group already contains $target_hostname"
fi

green "Updaing keys to secrets"
sops updatekeys --yes "$SOPS_SECRETS"

green "Copying ssh host keypair to target..."
scp -r -P $ssh_port $SCP_OPTS $temp_dir/ssh/* $target_user@$target_destination:/etc/ssh/

green "Running nixos-anywhere..."
sudo nix run github:nix-community/nixos-anywhere -- --target-host $target_user@$target_destination --flake .#$flake_host --copy-host-keys

