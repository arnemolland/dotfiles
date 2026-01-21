# Placeholder hardware configuration for the desktop host.
# Replace this file with the generated version from the target machine:
#   sudo nixos-generate-config --show-hardware-config \
#     > nix/nixos/hosts/desktop/hardware-configuration.nix
# This should include disk/LUKS/btrfs layout, boot devices, and GPU-specific kernel modules.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];
}
