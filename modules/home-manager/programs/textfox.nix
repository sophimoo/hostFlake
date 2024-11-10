{ pkgs, lib, config, inputs, ... }:

  let

    name = "textfox-sophie";

    textfox = pkgs.fetchzip {
      url = "https://github.com/sophimoo/textfox/archive/refs/heads/main.zip";
      sha256 = "0vvs8dzs9rzykffyasg29d9dfizgpxshrv5zwzmqaifalkqwx5ri";
    };

  in

{

  options = {
    textfox.enable =
        lib.mkEnableOption "enables textfox";
  };

  config = lib.mkIf config.textfox.enable {

    programs = {

      firefox = {
        enable = true;
        profiles."${name}" = {

          name = "TUI Sophie <3";
          id = 0;

          search = {
            force = true; # Firefox often replaces the symlink, so force on update
            default = "Startpage";
            engines = {
              "Startpage" = {
                urls = [{ template = "https://startpage.com/rvd/search?query={searchTerms}&language=auto"; }];
                iconUpdateURL = "https://www.startpage.com/sp/cdn/favicons/mobile android-icon-192x192.png";
                updateInterval = 24 * 60 * 60 * 1000; # every day
                definedAliases = [ "@s" ];
              };
            };
          };

          settings = {
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "svg.context-properties.content.enabled" = true;
            "layout.css.has-selector.enabled" = true;

            "shyfox.enable.ext.mono.toolbar.icons" = true;
            "shyfox.enable.ext.mono.context.icons" = true;
            "shyfox.enable.context.menu.icons" = true;

            "browser.discovery.enabled" = false;
            "extensions.getAddons.showPane" = false;
            "extensions.htmlaboutaddons.recommendations.enabled" = false;

            "browser.tabs.inTitlebar" = 0;
            "browser.aboutConfig.showWarning" = false;
            "browser.toolbars.bookmarks.visibility" = "always";
          };

          extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
            multi-account-containers
            adaptive-tab-bar-colour
            userchrome-toggle
            auto-tab-discard
            ublock-origin
            canvasblocker
            bitwarden
            sidebery
          ];

          containersForce = true;
          containers = {
            Protonmail = {   color = "pink";  icon = "briefcase";  id = 10; };
            Cockmail = { color = "turquoise"; icon = "briefcase"; id = 9; };
            University = { color = "blue"; icon = "briefcase"; id = 8; };
            Mailbox = { color = "green"; icon = "briefcase"; id = 7; };
            Yahoo = { color = "purple"; icon = "briefcase"; id = 6; };
            Microsoft = { color = "green"; icon = "fruit"; id = 5; };
            Apple = { color = "turquoise"; icon = "fruit"; id = 4; };
            Google = { color = "yellow"; icon = "fruit"; id = 3; };
            Whatsapp = { color = "green"; icon = "tree"; id = 2; };
            Reddit = { color = "orange"; icon = "pet"; id = 1; };
          };

          bookmarks = [
            {
              name = "Protonmail";
              tags = "email";
              url = "https://mail.proton.me";
            }
            {
              name = "Mailbox";
              tags = "email";
              url = "https://mail.proton.me";
            }
            {
              name = "Yahoo mail";
              tags = "email";
              url = "https://mail.yahoo.com/";
            }
          ];

        };

      };

    };

    home.file."${config.home.homeDirectory}/.mozilla/firefox/${name}/chrome/" = {
      source = "${textfox}/chrome";
      recursive = true;
    };
    home.file."${config.home.homeDirectory}/.mozilla/firefox/${name}/sidebery-settings.json" = {
      source = "${textfox}/sidebery-settings.json";
    };

  };

}

