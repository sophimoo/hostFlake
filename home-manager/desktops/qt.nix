{
  lib,
  config,
  pkgs,
  ...
}:

{

  options = {
    qt-config.enable = lib.mkEnableOption "enables qt config";
  };



  config = lib.mkIf config.qt-config.enable {

    home.packages = with pkgs; [
      libsForQt5.qtstyleplugin-kvantum
      libsForQt5.qt5ct
    ];

    qt = {
      enable = true;
      platformTheme = "qtct";
      style.name = "kvantum";
    };

    xdg.configFile = {
      "Kvantum/Graphite".source = "${pkgs.graphite-kde-theme}/share/Kvantum/Graphite";
      "Kvantum/kvantum.kvconfig".text = "[General]\ntheme=Graphite";
    };

  };
}
