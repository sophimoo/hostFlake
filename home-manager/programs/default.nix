{ pkgs, lib, ... }:
{

  imports = [
    ./firefox.nix
    ./btop.nix
    ./kitty.nix
    ./textfox.nix
    ./spicetify.nix
    ./lf.nix
    ./rstudio-stat.nix
    ./vscode.nix
  ];

}
