{ pkgs, lib, ... }: {

  imports = [

    ./home-manager/programs/firefox.nix

    ./home-manager/programs/textfox.nix

    ./home-manager/programs/btop.nix

    ./home-manager/overlays/discord.nix

  ];

}
