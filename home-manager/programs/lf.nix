{
  lib,
  config,
  pkgs,
  ...
}:

{

  options = {
    lf.enable = lib.mkEnableOption "enables lf";
  };

  config = lib.mkIf config.lf.enable {

    xdg.configFile."lf/icons".source = ./icons;

    programs = {

      lf = {
        enable = true;

        settings = {
          drawbox = true;
          hidden = true;
          preview = true;
          icons = true;
        };

        extraConfig = ''
          set previewer ctpv
          set cleaner ctpvclear
          &ctpv -s $id
          &ctpvquit $id
        '';
      };

    };

    home.packages = with pkgs; [ ctpv ];

  };

}
