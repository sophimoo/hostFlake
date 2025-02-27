{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

let

  name = "sophie";

in

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.

  imports = [ ../../home-manager ];

  discordOverlay.enable = false;
  # if this is enabled while having already used firefox on the system home-manager will fail due to .mozilla conflict

  spicetify.enable = true;
  firefox.enable = true;
  textfox.enable = true;
  kitty.enable = true;
  lf.enable = true;

  plasma-config.enable = true;
  gtk-config.enable = true;
  qt-config.enable = false;

  home.username = "${name}";
  home.homeDirectory = "/home/${name}";

  home.packages = with pkgs; [

    # discord

    goofcord
    arrpc

    jetbrains.pycharm-community

    gamemode
    mangohud
    protonup
    lutris
    wine
    rpcs3

    texliveFull

    qimgv
    mpv

    gimp-with-plugins

    libreoffice-qt6-fresh

    neovim
    ffmpeg
    wget
    git
    gh
    ranger
    rsync
    fastfetch
    atuin
    tmux
    tree
    p7zip
    rar

    chromium

    filelight
    gparted

    wireguard-tools

    btop-rocm

    python312
    python312Packages.pip
    virtualenv

    vdhcoapp

  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
