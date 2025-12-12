{
  config,
  lib,
  pkgs,
  ...
}:

let
  name = "sophie";
in

{

  options = {
    ly.enable = lib.mkEnableOption "enables ly";
  };

  config = lib.mkIf config.ly.enable {
    services.displayManager.ly = {
      enable = true;
      settings = {

      };
    };
  };
}
