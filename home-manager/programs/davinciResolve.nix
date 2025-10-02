{
  lib,
  config,
  pkgs,
  ...
}:

{
  options.davinciResolve.enable = lib.mkEnableOption "Enable Davinci Resolve custom desktop entry";

  config = lib.mkIf config.davinciResolve.enable {
    home.packages = [
      pkgs.davinci-resolve
    ];

    # Desktop entry
    xdg.desktopEntries.davinci-resolve = {
      name = "Davinci Resolve";
      genericName = "Video Editor";
      comment = "Professional video editing, color, effects and audio post-processing";
      exec =
        let
          script = pkgs.writeShellScriptBin "resolve-wrapper" ''
            #!/bin/sh
            qdbus org.kde.kded6 /kded org.kde.kded6.unloadModule appmenu
            exec ${pkgs.davinci-resolve}/bin/davinci-resolve "$@"
            qdbus org.kde.kded6 /kded org.kde.kded6.loadModule appmenu
          '';
        in
        "${script}/bin/resolve-wrapper %U";
      icon = "davinci-resolve";
      type = "Application";
      categories = [
        "AudioVideo"
        "AudioVideoEditing"
        "Video"
        "Graphics"
      ];
    };
  };
}
