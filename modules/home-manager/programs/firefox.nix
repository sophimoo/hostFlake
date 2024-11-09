{ pkgs, lib, config, inputs, ... }:

  let

    name = "sophie";

    edgyArcChrome = pkgs.fetchzip {
      url = "https://github.com/artsyfriedchicken/EdgyArc-fr/archive/refs/heads/main.zip";
      sha256 = "0ij4bz2z6ny83fax70h8i6rzlzh49k9jz1ihj2yqjrh76c6xiz1a";
    };

  in

{

  options = {
    firefox.enable =
        lib.mkEnableOption "enables firefox";
  };

  config = lib.mkIf config.firefox.enable {

    programs = {

      firefox = {
        enable = true;
        profiles."firefox-${name}" = {

          name = "Sophie <3";
          id = 0;
          isDefault = true;

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
            "uc.tweak.hide-tabs-bar" = true;
            "uc.tweak.hide-forward-button" = true;
            "uc.tweak.rounded-corners" = true;
            "uc.tweak.floating-tabs" = true;
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "svg.context-properties.content.enabled" = true;
            "layout.css.color-mix.enabled" = true;
            "layout.css.light-dark.enabled" = true;
            "layout.css.has-selector.enabled" = true;
            "af.edgyarc.centered-url" = true;
            "af.sidebery.edgyarc-theme" = true;
            "af.edgyarc.edge-sidebar" = true;

            "browser.discovery.enabled" = false;
            "extensions.getAddons.showPane" = false;
            "extensions.htmlaboutaddons.recommendations.enabled" = false;

            "browser.aboutConfig.showWarning" = false;
            "browser.toolbars.bookmarks.visibility" = "always";
          };

          extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
            sidebery
            userchrome-toggle
            adaptive-tab-bar-colour
            bitwarden
            ublock-origin
            canvasblocker
            multi-account-containers
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

        };

      };

    };

    home.file."${config.home.homeDirectory}/.mozilla/firefox/${name}/chrome/" = {
      source = "${edgyArcChrome}/chrome";
      recursive = true;
    };
    home.file."${config.home.homeDirectory}/.mozilla/firefox/${name}/sidebery/" = {
      source = "${edgyArcChrome}/Sidebery";
      recursive = true;
    };

  };

}
