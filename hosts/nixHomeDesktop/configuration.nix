# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  fetchpatch,
  ...
}:

let
  name = "sophie";
in

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/hardware
  ];

  # Bootloader
  boot = {

    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;
        configurationLimit = 5;
      };
      timeout = 5;
    };

    kernelParams = [ "amd_iommu=on" ];

    plymouth = {
      enable = true;
      theme = "breeze";
    };

  };

  networking.hostName = "nixHomeDesktop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.UTF-8";
    LC_IDENTIFICATION = "de_AT.UTF-8";
    LC_MEASUREMENT = "de_AT.UTF-8";
    LC_MONETARY = "de_AT.UTF-8";
    LC_NAME = "de_AT.UTF-8";
    LC_NUMERIC = "de_AT.UTF-8";
    LC_PAPER = "de_AT.UTF-8";
    LC_TELEPHONE = "de_AT.UTF-8";
    LC_TIME = "de_AT.UTF-8";
  };

  services.xserver = {

    enable = true;
    autorun = false;
    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
    };

    videoDrivers = [ "nvidia" ];

  };

  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;
  # Enable hyprland
  programs.hyprland.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --remember-session --asterisks --time --greeting '${name} on nixOS!'";
        user = "greeter";
      };
    };
  };

  systemd.tmpfiles.rules = [ "d '/var/cache/tuigreet' - greeter greeter - -" ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  security.sudo.extraConfig = ''
    Defaults env_reset,pwfeedback
    Defaults env_keep += "EDITOR VISUAL"
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${name} = {
    isNormalUser = true;
    description = "${name}";
    extraGroups = [
      "networkmanager"
      "wheel"
      #       "libvirtd"
    ];
    packages = with pkgs; [
      kdePackages.kate
      #  thunderbird
    ];
  };

  # nix stuff
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  # Enable flatpak
  services.flatpak.enable = true;

  # Required for flatpak
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  programs = {

    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      extest.enable = true;
    };

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
      shellInit = "
        atuin init fish | source\n
        set fish_greeting # Disable greeting\n
        fastfetch\n
      ";
    };

    appimage = {
      enable = true;
      binfmt = true;
    };

  };

  environment = {

    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };

    sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/user/.steam/root/compatibilitytools.d";
    };

    systemPackages = with pkgs; [

      pkgsi686Linux.gperftools
      gperftools
      appimage-run
      greetd.tuigreet

      miracode
      lexend
      monocraft
      nerdfonts

      nixfmt-rfc-style

      #       virtio-win
      #       virt-manager
      #       virt-viewer
      #       spice
      #       spice-gtk
      #       spice-protocol
      #       win-virtio
      #       win-spice
    ];

  };

  #   services.spice-vdagentd.enable = true;
  #
  #   virtualisation = {
  #
  #     virtualbox = {
  #       host = {
  #         enable = true;
  #         enableKvm = true;
  #         enableExtensionPack = true;
  #         addNetworkInterface = false;
  #       };
  #       guest = {
  #         enable = true;
  #         clipboard = true;
  #         draganddrop = true;
  #       };
  #     };
  #
  #     libvirtd = {
  #       enable = true;
  #       qemu = {
  #         package = pkgs.qemu_kvm;
  #         runAsRoot = true;
  #         swtpm.enable = true;
  #         ovmf = {
  #           enable = true;
  #           packages = [
  #             (pkgs.OVMF.override {
  #               secureBoot = true;
  #               tpmSupport = true;
  #             }).fd
  #           ];
  #         };
  #       };
  #     };
  #     spiceUSBRedirection.enable = true;
  #   };
  #
  #   users.extraGroups.vboxusers.members = [ "${name}" ];

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ ];
  };

  # Load nvidia driver for Xorg and Wayland
  nvidiaHome.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
