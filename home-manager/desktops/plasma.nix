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

    programs.plasma = {
      enable = true;

      #
      # Some high-level settings:
      #
      workspace = {
        clickItemTo = "select";
        lookAndFeel = "org.kde.breezedark.desktop";
        cursor = {
          theme = "Bibata-Modern-Ice";
          size = 32;
        };
        iconTheme = "Papirus-Dark";
        wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Patak/contents/images/1080x1920.png";
      };

      hotkeys.commands."launch-konsole" = {
        name = "Launch Konsole";
        key = "Meta+Alt+K";
        command = "kitty";
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
            {
              kickoff = {
                sortAlphabetically = true;
                icon = "nix-snowflake";
              };
            }
            "org.kde.plasma.marginsseparator"
            {
              iconTasks = {
                launchers = [
                  "applications:org.kde.dolphin.desktop"
                  "firefox.desktop"
                  "kitty.desktop"
                ];
              };
            }
          ];
          hiding = "autohide";
          floating = true;
          lengthMode = "fit";
        }
        # Application name, Global menu and Song information and playback controls at the top
        {
          location = "top";
          height = 32;
          widgets = [
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
              systemTray.items = { };
            }
            {
              name = "org.kde.plasma.digitalclock";
              config = {
                General = {
                  autoFontAndSize = false;
                  customDateFormat = "ddd d MMM";
                  dateFormat = "custom";
                  fontFamily = "Noto Sans";
                  fontStyleName = "Regular";
                  fontWeight = "400";
                  use24hFormat = "2";
                  dateDisplayFormat = "BesideTime";
                };
              };
            }
          ];
        }
      ];

      powerdevil = {
        AC = {
          powerButtonAction = "lockScreen";
          autoSuspend = {
            action = "nothing";
          };
          turnOffDisplay = {
            idleTimeout = 1000;
            idleTimeoutWhenLocked = "immediately";
          };
        };
        battery = {
          powerButtonAction = "sleep";
          whenSleepingEnter = "standbyThenHibernate";
        };
        lowBattery = {
          whenLaptopLidClosed = "hibernate";
        };
      };

    };
  };

}
