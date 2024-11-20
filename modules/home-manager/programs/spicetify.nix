{ lib, inputs, pkgs, config, ... }:

{

  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  options = {
    spicetify.enable = lib.mkEnableOption "enables spicetify & spotify";
  };

  config = lib.mkIf config.spicetify.enable {
    programs = {
      spicetify =
        let
            spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
        in
      {
        enable = true;
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

