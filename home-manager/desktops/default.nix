{ pkgs, lib, ... }:
{

  imports = [
    ./plasma.nix
    ./gtk.nix
    ./qt.nix
  ];

}
