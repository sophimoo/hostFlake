{
  lib,
  config,
  pkgs,
  ...
}:

let

  sophie-wallpaper = pkgs.fetchzip {
    url = "https://github.com/sophimoo/wallpapers/archive/refs/heads/main.zip";
    sha256 = "1j9dpw2jg5hss7gzky65fakz3phnhhs7x7hc05w26pd4wb128w7c";
  };

in

{

  options = {
    plasma-config.enable = lib.mkEnableOption "enables plasma config";
  };

  config = lib.mkIf config.plasma-config.enable {

    gtk-config.enable = true;
    qt-config.enable = true;

    home.packages = with pkgs; [
      papirus-icon-theme
    ];

    programs.plasma = {
      enable = true;
      #
      # Some high-level settings:
      #
      workspace = {
        clickItemTo = "select";
        # iconTheme = "Colloid-Light";
        iconTheme = "Papirus";
        lookAndFeel = "Monochrome";
        # wallpaper = "/home/sophie/Documents/wallpapers/mc_wallpaper_reversed_night.jpg";
        wallpaper = "${sophie-wallpaper}/mc_wallpaper_reversed_night.jpg";
      };

      kscreenlocker = {
        passwordRequired = false;
      };

      session = {
        sessionRestore = {
          restoreOpenApplicationsOnLogin = "startWithEmptySession";
        };
      };

      hotkeys.commands."launch-kitty" = {
        name = "Launch Kitty";
        key = "Meta+Alt+K";
        command = "kitty";
      };

      krunner = {
        position = "center";
        historyBehavior = "enableSuggestions";
      };

      fonts = {
        general = {
          family = "Lexend";
          pointSize = 10;
        };
        fixedWidth = {
          family = "Hack";
          pointSize = 10;
        };
        small = {
          family = "Lexend";
          pointSize = 8;
        };
        toolbar = {
          family = "Lexend";
          pointSize = 10;
        };
        menu = {
          family = "Lexend";
          pointSize = 10;
        };
        windowTitle = {
          family = "Lexend";
          pointSize = 10;
        };
      };

      panels = [
        # Windows-like panel at the bottom
        {
          location = "bottom";
          widgets = [
            "org.kde.plasma.trash"
            {
              iconTasks = {
                launchers = [
                  "applications:org.kde.dolphin.desktop"
                  "applications:firefox.desktop"
                  "applications:kitty.desktop"
                ];
              };
            }
          ];
          hiding = "dodgewindows";
          floating = true;
          lengthMode = "fit";
        }
        {
          location = "top";
          height = 32;
          widgets = [
            {
              kicker = {
                icon = "nix-snowflake";
              };
            }
            {
              applicationTitleBar = {
                behavior = {
                  activeTaskSource = "activeTask";
                };
                layout = {
                  elements = [ "windowTitle" ];
                  horizontalAlignment = "left";
                  showDisabledElements = "deactivated";
                  verticalAlignment = "center";
                };
                overrideForMaximized.enable = false;
                windowTitle = {
                  font = {
                    bold = false;
                    fit = "fixedSize";
                    size = 10;
                  };
                  hideEmptyTitle = true;
                  margins = {
                    bottom = 0;
                    left = 10;
                    right = 5;
                    top = 0;
                  };
                  source = "appName";
                };
              };
            }
            "org.kde.plasma.appmenu"
            "org.kde.plasma.panelspacer"
            {
              digitalClock = {
                time.format = "24h";
                font = {
                  family = "Lexend Deca Medium";
                  size = 10;
                };
                date = {
                  format.custom = "ddd d MMM";
                  position = "besideTime";
                };
              };
            }
            "org.kde.plasma.panelspacer"
            {
              systemTray = { };
            }
          ];
        }
      ];

      powerdevil = {
        AC = {
          powerButtonAction = "lockScreen";
          turnOffDisplay = {
            idleTimeout = 1000;
            idleTimeoutWhenLocked = "immediately";
          };
        };
      };

    };
  };

}
