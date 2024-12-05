{
  config,
  lib,
  pkgs,
  ...
}:
{

  options = {
    fonts.enable = lib.mkEnableOption "enables fonts";
  };

  config = lib.mkIf config.fonts.enable {
    fonts.packages = with pkgs; [
      nerdfonts
      lexend
      miracode
      monocraft
    ];
  };

}
