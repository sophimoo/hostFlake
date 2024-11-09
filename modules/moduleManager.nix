{ pkgs, lib, ... }: {

  imports = [

    ./home-manager/programs/firefox.nix

    ./home-manager/overlays/discord.nix

  ];

}
