{ pkgs, lib, config, inputs, ... }:

{

  options = {
    stylixStyling.enable =
        lib.mkEnableOption "enables stylix";
  };

  config = lib.mkIf config.stylixStyling.enable {

    stylix.enable = true;

    stylix.image = ./wallpaper.png;

  };

}
