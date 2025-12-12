{
  config,
  lib,
  pkgs,
  ...
}:
{

  options = {
    obsConfig.enable = lib.mkEnableOption "enables obs with plugins";
  };

  config = lib.mkIf config.obsConfig.enable {
    programs.obs-studio = {
      enable = true;

      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-vaapi # optional AMD hardware acceleration
        obs-gstreamer
        obs-vkcapture
        input-overlay
      ];
    };
  };

}
