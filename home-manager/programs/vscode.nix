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

  config = lib.mkIf config.vscode.enable {

    programs.vscode = {
      enable = true;
      package = pkgs.vscode.fhs;
    };

  };

}
