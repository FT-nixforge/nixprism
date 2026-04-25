# ft-nixlaunch — base config
#
# Installs the ft-nixlaunch package into the user's home.packages.
# The package reference comes from the flake's `self` output, which is
# injected into the module system as `ft-nixlaunchSelf` via _module.args
# in modules/home.nix.
{ config, lib, pkgs, ft-nixlaunchSelf, ... }:

{
  config = lib.mkIf config.programs.ft-nixlaunch.enable {
    home.packages = [
      ft-nixlaunchSelf.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
