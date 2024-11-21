{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{

  options = {
    discordOverlay.enable = lib.mkEnableOption "enables discord overlay";
  };

  config = lib.mkIf config.discordOverlay.enable {

    nixpkgs.overlays = [
      (self: super: {
        discord = super.discord.overrideAttrs (_: {
          src = builtins.fetchTarball {
            url = "https://discord.com/api/download?platform=linux&format=tar.gz";
            sha256 = "17pflznmwhpf9686hbka8jnhwa56v0741haqnjjpfg9847fifi7r";
          };
        });
      })
    ];

  };

}
