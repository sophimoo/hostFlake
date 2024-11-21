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
    # nix run nixpkgs#wget -- "https://raw.githubusercontent.com/gokcehan/lf/master/etc/icons.example" -O icons

    programs = {

      lf = {
        enable = true;

        commands = {
          dragon-out = ''%${pkgs.xdragon}/bin/xdragon -a -x "$fx"'';
          editor-open = ''$$EDITOR $f'';
          mkdir = ''
          ''${{
            printf "Directory Name: "
            read DIR
            mkdir $DIR
          }}
          '';
        };

        settings = {
          drawbox = true;
          hidden = true;
          preview = true;
          icons = true;
	  mouse = true;
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
