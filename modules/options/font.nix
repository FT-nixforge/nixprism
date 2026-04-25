# Font options for ft-nixlaunch.
# Declares programs.ft-nixlaunch.font.* options consumed by the theme generator.
{ lib, ... }:

{
  options.programs.ft-nixlaunch.font = {
    name = lib.mkOption {
      type        = lib.types.str;
      default     = "Inter";
      description = ''
        Font family name used throughout the launcher.
        Make sure the font is installed on your system — either via
        `home.packages`, `fonts.packages` (NixOS), or Stylix font defaults.
      '';
      example = "JetBrainsMono Nerd Font";
    };

    size = lib.mkOption {
      type        = lib.types.int;
      default     = 13;
      description = ''
        Base font size in points.
        The prompt uses Bold at this size; the mode-switcher buttons are
        rendered 2pt smaller and the message textbox 3pt smaller.
      '';
      example = 14;
    };
  };
}
