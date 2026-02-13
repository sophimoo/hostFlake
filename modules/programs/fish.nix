{
  config,
  lib,
  pkgs,
  ...
}:
{

  options = {
    fishShell.enable = lib.mkEnableOption "enables fish shell with bash integration";
  };

  config = lib.mkIf config.fishShell.enable {
    programs = {
      bash = {
        interactiveShellInit = ''
          if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
          then
            shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
            exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
          fi
        '';
      };

      fish = {
        enable = true;
        shellInit = ''
                    atuin init fish | source
                    set fish_greeting # Disable greeting
                    fastfetch
                    function lf
              		set -l dir (command lf -print-last-dir $argv)
              		if test -n "$dir"
                  		cd "$dir"
              		end
          	    end
          	  '';
      };
    };

    environment.systemPackages = with pkgs; [
      atuin
      fastfetch
    ];
  };

}
