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
    ../../modules
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
    kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [
      "quiet"
      "amd_iommu=on"
      "iommu=pt"
      "pcie_acs_override=downstream,multifunction"
      "video=efifb:off"
      "vfio-pci.ids=1002:164e,1002:1640" # Raphael
      #       "vfio-pci.ids=1002:747e,1002:ab30" # 7700XT
    ];
    extraModulePackages = with config.boot.kernelPackages; [
      kvmfr
      vendor-reset
    ];
    extraModprobeConfig = ''
      options kvmfr static_size_mb=32
    '';
    initrd.kernelModules = [
      "vendor-reset"
      "kvmfr"
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
    ];
    plymouth = {
      enable = true;
      theme = "breeze";
    };
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="kvmfr", OWNER="${name}", GROUP="qemu-libvirtd", MODE="0660"
  '';

  # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking = {
    hostName = "nixHomeDesktop";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      # if packets are still dropped, they will show up in dmesg
      logReversePathDrops = true;
      # wireguard trips rpfilter up
      extraCommands = ''
        ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
        ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
      '';
      extraStopCommands = ''
        ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
        ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
      '';
    };
  };

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
    displayManager.startx.enable = true;
    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;
  # Enable hyprland
  programs.hyprland.enable = true;

  tuigreet.enable = true;

  systemd.tmpfiles.rules =
    let
      rocmEnv = pkgs.symlinkJoin {
        name = "rocm-combined";
        paths = with pkgs.rocmPackages; [
          rocblas
          hipblas
          clr
        ];
      };
    in
    [
      "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
    ];
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  # services.pulseaudio.enable = false;
  # rtkit (optional, recommended) allows Pipewire to use the realtime scheduler for increased performance.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true; # if not already enabled
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment the following
    #jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  security.pam = {
    # If enabled, pam_wallet will attempt to automatically unlock the user’s default KDE wallet upon login.
    # If the user has no wallet named “kdewallet”, or the login password does not match their wallet password,
    # KDE will prompt separately after login.
    services = {
      ${name} = {
        kwallet = {
          enable = true;
          package = pkgs.kdePackages.kwallet-pam;
        };
      };
    };
  };

  security.sudo = {
    wheelNeedsPassword = false;
    extraConfig = ''
      Defaults env_reset,pwfeedback
      Defaults env_keep += "EDITOR VISUAL"
      Defaults timestamp_timeout=60
    '';
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${name} = {
    isNormalUser = true;
    description = "${name}";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "docker"
      "render"
      "video"
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
    xdgOpenUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  zramSwap.enable = true;

  steamGaming.enable = true;

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
        alias beammp "protontricks-launch -vv --appid 284160 '/run/media/sophie/2TB SSD/SteamLibrary/steamapps/compatdata/284160/pfx/drive_c/users/steamuser/AppData/Roaming/BeamMP-Launcher/BeamMP-Launcher.exe'"

        echo -n -s "$nix_shell_info ~>"
      '';
      promptInit = ''
        set -l nix_shell_info (
          if test -n "$IN_NIX_SHELL"
            echo -n "<nix-shell> "
          end
        )

      '';
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
      RUSTICL_ENABLE = "radeonsi";
      # QT_QPA_PLATFORMTHEME = "qt5ct";
    };

    systemPackages = with pkgs; [
      lmstudio

      gpu-screen-recorder-gtk

      pkgsi686Linux.gperftools
      gperftools
      appimage-run

      nixfmt-rfc-style
      exfatprogs
      protontricks

      clinfo
      pciutils

      (pkgs.symlinkJoin {
        name = "looking glass";
        buildInputs = [ pkgs.makeWrapper ];
        paths = [ pkgs.looking-glass-client ];
        postBuild = ''
          wrapProgram $out/bin/looking-glass-client \
            --set __NV_DISABLE_EXPLICIT_SYNC 1
        '';
      })

      virt-viewer
      spice
      spice-gtk
      spice-protocol
      virtio-win
      virtiofsd
      win-virtio
      win-spice

    ];

  };

  programs.virt-manager.enable = true;
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [
            (pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd
          ];
        };
        vhostUserPackages = with pkgs; [ virtiofsd ];
        verbatimConfig = ''
          cgroup_device_acl = [
              "/dev/null",
              "/dev/full",
              "/dev/zero",
              "/dev/random",
              "/dev/urandom",
              "/dev/ptmx",
              "/dev/kvm",
              "/dev/userfaultfd",
              "/dev/kvmfr0"
          ]
        '';
      };
    };
    spiceUSBRedirection.enable = true;
  };

  fonts = {
    enable = true;
    enableDefaultPackages = true;
    fontDir.enable = true;
  };

  hardware.logitech.wireless.enable = true;
  programs.gpu-screen-recorder.enable = true;

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      mesa
      mesa.opencl
      rocmPackages.rocblas
      rocmPackages.rocm-smi
      rocmPackages.rocminfo
      rocmPackages.hipblas
      rocmPackages.rocm-device-libs
      rocmPackages.rpp
      pcre2
      libselinux
      libcap
    ];
  };

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
