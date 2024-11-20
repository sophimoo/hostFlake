{ lib, config, ... }:

{

  options = {
    kitty.enable = lib.mkEnableOption "enables kitty";
  };

  config = lib.mkIf config.kitty.enable {
    programs = {
      kitty = {
        enable = true;
        settings = {
          confirm_os_window_close = 0;
          dynamic_background_opacity = true;
          enable_audio_bell = false;
          mouse_hide_wait = "-1.0";
          window_padding_width = 10;
          background_opacity = "0.75";
          background_blur = 10;
          remember_window_size = "no";
          resize_in_steps = "no";
          initial_window_width = "120c";
          initial_window_height = "34c";
          tab_bar_style = "powerline";
          tab_bar_min_tabs = 0;
        };
      };
    };
  };
}
