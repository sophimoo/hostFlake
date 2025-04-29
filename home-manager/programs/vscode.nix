{
  lib,
  config,
  pkgs,
  ...
}:

{

  options = {
    vscode.enable = lib.mkEnableOption "enables vscode";
  };

  config = lib.mkIf config.rStudio-stat.enable {


  };

}
