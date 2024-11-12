{ config, pkgs, inputs, lib, ... }:

  let

    name = "sophie";

  in

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.

  imports = [
    ../../modules/moduleManager.nix
  ];

  discordOverlay.enable = false;
  # if this is enabled while having already used firefox on the system home-manager will fail due to .mozilla conflict
  firefox.enable = true;
  textfox.enable = true;
  btop.enable = true;

  home.username = "${name}";
  home.homeDirectory = "/home/${name}";
  
  home.packages = with pkgs; [

    # discord

    jetbrains.pycharm-community

    gamemode
    mangohud
    protonup

    qimgv
    mpv
    kitty

    neovim
    ffmpeg
    wget
    git
    gh
    ranger
    lf
    rsync
    btop
    fastfetch
    atuin
    tmux

  ];

  services.flatpak.update.onActivation = true;
  services.flatpak.uninstallUnmanaged = false;

  services.flatpak.packages = [
    # { appID = ""; origin = ""; }
    "org.prismlauncher.PrismLauncher"
    "io.github.milkshiift.GoofCord"
    "org.qbittorrent.qBittorrent"
    "org.libreoffice.LibreOffice"
    "net.cozic.joplin_desktop"
    "org.mozilla.Thunderbird"
    "com.discordapp.Discord"
    "com.usebottles.bottles"
    "com.bitwarden.desktop"
    "com.obsproject.Studio"
    "com.spotify.Client"
    "org.signal.Signal"
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
