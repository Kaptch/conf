#!/usr/bin/env bash

# Create a temporary directory
temp=$(mktemp -d)

# Function to cleanup temporary directory on exit
cleanup() {
  rm -rf "$temp"
}
trap cleanup EXIT

# Create the directory where sshd expects to find the host keys
install -d -m755 "$temp/etc/ssh"

# Decrypt your private key and copy it to the temporary directory
gpg --output $temp/etc/ssh/ssh_host_ed25519_key --decrypt ../ssh_host_ed25519_key.gpg
echo $1 > $temp/disk.key

# Set the correct permissions so sshd will accept the key
chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"

# Install NixOS to the host system with our secrets
nixos-anywhere --extra-files "$temp" --disk-encryption-keys $temp/disk.key $temp/disk.key --flake '.#$2' root@$3
