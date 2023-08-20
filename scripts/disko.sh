#!/usr/bin/env bash

sudo nix run github:nix-community/disko -- --mode disko ../disks/$1 --arg disks '[ "/dev/$2" ]'

mount | grep /mnt
