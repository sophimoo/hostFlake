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

    home = {
      packages = with pkgs; [
        libsForQt5.qtstyleplugin-kvantum
        libsForQt5.qt5ct
        (stdenv.mkDerivation rec {
          pname = "monochrome-kde-theme";
          version = "master";
          src = fetchFromGitLab {
            owner = "pwyde";
            repo = "monochrome-kde";
            rev = "master";
            sha256 = "sha256-mnEQQ2PHzARv65PSwGDyS2bcYlRUydD5HUmVD251Tts=";
          };

          dontBuild = true;
          installPhase = ''
            mkdir -p $out/share
            cp -R aurorae $out/share/
            cp -R color-schemes $out/share/
            cp -R konsole $out/share/
            cp -R Kvantum $out/share/
            cp -R plasma $out/share/
            cp -R yakuake $out/share/
          '';
        })
      ];
    };

    qt = {
      enable = true;
      platformTheme.name = "qt5ct";
      style.name = "kvantum";
    };

    xdg.configFile = {
      "Kvantum/MonochromeBlur".source = "${
        (pkgs.fetchFromGitHub {
          owner = "pwyde";
          repo = "monochrome-kde";
          rev = "1c9983e8d1384ec2d9ff0fac59c5265fc74d0e6b";
          sha256 = "sha256-mnEQQ2PHzARv65PSwGDyS2bcYlRUydD5HUmVD251Tts=";
        })
      }/Kvantum/MonochromeBlur";
      "Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=MonochromeBlur
      '';
    };

  };

}
