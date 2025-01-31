{
  lib,
  inputs,
  pkgs,
  config,
  ...
}:

{

  options = {
    spicetify = {
      enable = lib.mkEnableOption {
        description = "enables spicetify & spotify";
        default = false;
      };
    };
  };

  config = lib.mkIf config.spicetify.enable {

    programs = {
      spicetify =
        let
          spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
        in
        {
          enable = true;
          spicetifyPackage = pkgs.spicetify-cli;
          enabledCustomApps = with spicePkgs.apps; [
            historyInSidebar
            marketplace
          ];
          enabledExtensions = with spicePkgs.extensions; [
            adblock
            hidePodcasts
            shuffle # shuffle+ (special characters are sanitized out of extension names)
          ];
          theme = spicePkgs.themes.text;
        };
    };
  };
}
