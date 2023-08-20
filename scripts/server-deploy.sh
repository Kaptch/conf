#!/usr/bin/env bash

nixos-rebuild switch --flake ../#openstack --target-host kaptch@$1 --build-host kaptch@$1 --use-remote-sudo
