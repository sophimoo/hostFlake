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
    fonts.packages =
      with pkgs;
      [
        lexend
        miracode
        monocraft
      ]
      ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  };

}
