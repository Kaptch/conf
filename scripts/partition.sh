#!/usr/bin/env bash

wipefs -a /dev/$1

parted -a optimal /dev/$1 -- mklabel gpt
parted -a optimal /dev/$1 -- mkpart ESP fat32 1MiB 513MiB
parted -a optimal /dev/$1 -- set 1 esp on
parted -a optimal /dev/$1 -- mkpart primary linux-swap 513MiB 8705MiB
parted -a optimal /dev/$1 -- mkpart primary 8705MiB 100%

mkfs.fat -F 32 -n boot /dev/"${1}1"

mkswap -L swap /dev/"${1}2"
swapon /dev/$1 2

zpool create -O mountpoint=none -O atime=off -o ashift=12 -O acltype=posixacl -O xattr=sa -O compression=zstd -O dnodesize=auto -O normalization=formD zroot /dev/"${1}3"
zfs create -o refreservation=1G -o mountpoint=none zroot/reserved
zfs create zroot/root

mount -t zfs -o zfsutil zroot/root /mnt
mkdir -p /mnt/boot
mount /dev/"${1}1" /mnt/boot
