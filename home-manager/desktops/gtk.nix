{
  lib,
  config,
  pkgs,
  ...
}:

{

  options = {
    gtk-config.enable = lib.mkEnableOption "enables gtk config";
  };

  config = lib.mkIf config.gtk-config.enable {
    gtk = {
      enable = true;
      #Icon Theme
      iconTheme = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
      };
      gtk2.configLocation = "${config.home.homeDirectory}/.config/.gtkrc-2.0";
    };
  };
}
