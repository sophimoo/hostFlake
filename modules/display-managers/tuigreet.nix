{
  config,
  lib,
  pkgs,
  ...
}:

let
  name = "sophie";
in

{

  options = {
    tuigreet.enable = lib.mkEnableOption "enables tuigreet";
  };

  config = lib.mkIf config.tuigreet.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --remember-session --asterisks --time --greeting '${name} on nixOS!'";
          user = "greeter";
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d '/var/cache/tuigreet' - greeter greeter - -"
    ];

    environment.systemPackages = with pkgs; [
      greetd.tuigreet
    ];
  };
}
