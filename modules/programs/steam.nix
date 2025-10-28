{ config, lib, pkgs, ... }:
{

  options = {
    steamGaming.enable = lib.mkEnableOption "enables steam for gaming";
  };

  config = lib.mkIf config.steamGaming.enable {
    environment = {
      sessionVariables = {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/user/.steam/root/compatibilitytools.d";
      };
    };

    programs = {
      steam = {
        enable = true;
        gamescopeSession.enable = true;
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
        localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
        extest.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      gamemode
      mangohud
      protonup
      lutris
      wine
    ];
  };

}
