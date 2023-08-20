#!/usr/bin/env bash

nix build ../#homeManagerConfigurations.$1.activationPackage
result/activate
