{ pkgs, lib, ... }: {

  imports = [

    ./home-manager/programs/firefox.nix

    ./home-manager/overlays/discord.nix

    ./home-manager/stylix/stylix.nix

  ];

}
