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

  config = lib.mkIf (config.spicetify.enable && inputs ? spicetify-nix) {

    programs = {
      spicetify =
        let
          spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
        in
        {
          enable = true;
          enabledCustomApps = with spicePkgs.apps; [
            historyInSidebar
            marketplace
          ];
          enabledExtensions = with spicePkgs.extensions; [
            adblock
            hidePodcasts
            shuffle
          ];

        };
    };
  };
}