{
  lib,
  config,
  pkgs,
  ...
}:

{

  options = {
    plasma-config.enable = lib.mkEnableOption "enables plasma config";
  };

  config = lib.mkIf config.plasma-config.enable {

    imports = [ <plasma-manager/modules> ];

    programs.plasma = {
      enable = true;

      #
      # Some high-level settings:
      #
      workspace = {
        clickItemTo = "select";
        cursor.theme = "Bibata-Modern-Ice";
      };

      hotkeys.commands."launch-konsole" = {
        name = "Launch Konsole";
        key = "Meta+Alt+K";
        command = "konsole";
      };

    };

  };

}
