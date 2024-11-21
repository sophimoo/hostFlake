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

        extraConfig =
            let
              previewer =
                pkgs.writeShellScriptBin "pv.sh" ''
                file=$1
                w=$2
                h=$3
                x=$4
                y=$5

                if [[ "$( ${pkgs.file}/bin/file -Lb --mime-type "$file")" =~ ^image ]]; then
                    ${pkgs.kitty}/bin/kitty +kitten icat --silent --stdin no --transfer-mode file --place "''${w}x''${h}@''${x}x''${y}" "$file" < /dev/null > /dev/tty
                    exit 1
                fi

                ${pkgs.pistol}/bin/pistol "$file"
              '';
              cleaner = pkgs.writeShellScriptBin "clean.sh" ''
                ${pkgs.kitty}/bin/kitty +kitten icat --clear --stdin no --silent --transfer-mode file < /dev/null > /dev/tty
              '';
            in
            ''
              set cleaner ${cleaner}/bin/clean.sh
              set previewer ${previewer}/bin/pv.sh
            '';

      };

    };

  };

}
