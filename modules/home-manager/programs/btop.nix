{ lib, config, ... }:

{

  options = {
    btop.enable = lib.mkEnableOption "enables btop";
  };

  config = lib.mkIf config.btop.enable {

    programs = {
      btop = {

        enable = true;
        settings = {
          theme_background = false;
          truecolor = false;
          update_ms = 100;
        };
      };
    };
  };
}
