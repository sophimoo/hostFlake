{
  lib,
  config,
  pkgs,
  ...
}:

{

  options = {
    rStudio-stat.enable = lib.mkEnableOption "enables rStudio-stat";
  };

  config = lib.mkIf config.rStudio-stat.enable {

    home.packages = with pkgs; [
      (rstudioWrapper.override {
        packages = with pkgs.rPackages; [
          summarytools
        ];
      })
    ];

  };

}
