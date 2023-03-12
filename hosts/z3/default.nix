{ pkgs, config, lib, ... }:
{
  imports = [
    ../home.nix
    ./hardware-configuration.nix
    # ./configuration.nix
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "python-2.7.18.6"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "z3"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  # networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  ## Modules
  modules = {
    desktop = {
      bspwm.enable = true;
      apps = {
        rofi.enable = true;
        # godot.enable = true;
      };
      browsers = {
        default = "brave";
        brave.enable = true;
        firefox.enable = true;
        qutebrowser.enable = true;
      };
      # gaming = {
      #   steam.enable = true;
      #   kernelPackages = pkgs.linuxPackages_latest;
      #   # emulators.enable = true;
      #   # emulators.psx.enable = true;
      # };
      media = {
        daw.enable = true;
        documents.enable = true;
        graphics.enable = true;
        mpv.enable = true;
        recording.enable = true;
        spotify.enable = true;
      };
      term = {
        default = "xst";
        st.enable = true;
      };
      vm = {
        qemu.enable = true;
      };
    };
    dev = {
      node.enable = true;
      rust.enable = true;
      python.enable = true;
    };
    editors = {
      default = "nvim";
      emacs.enable = true;
      vim.enable = true;
    };
    shell = {
      adl.enable = true;
      vaultwarden.enable = true;
      direnv.enable = true;
      git.enable = true;
      gnupg.enable = true;
      tmux.enable = true;
      zsh.enable = true;
    };
    services = {
      ssh.enable = true;
      docker.enable = true;
      # Needed occasionally to help the parental units with PC problems
      # teamviewer.enable = true;
    };
    theme.active = "alucard";
  };


  ## Local config
  programs.ssh.startAgent = true;
  services.openssh.startWhenNeeded = true;

  networking.networkmanager.enable = true;


  ## Personal backups
  # Syncthing is a bit heavy handed for my needs, so rsync to my NAS instead.
  systemd = {
    services.backups = {
      description = "Backup /usr/store to NAS";
      wants = [ "usr-drive.mount" ];
      path = [ pkgs.rsync ];
      environment = {
        SRC_DIR = "/usr/store";
        DEST_DIR = "/usr/drive";
      };
      script = ''
        rcp() {
          if [[ -d "$1" && -d "$2" ]]; then
            echo "---- BACKUPING UP $1 TO $2 ----"
            rsync -rlptPJ --chmod=go= --delete --delete-after \
                --exclude=lost+found/ \
                --exclude=@eaDir/ \
                --include=.git/ \
                --filter=':- .gitignore' \
                --filter=':- $XDG_CONFIG_HOME/git/ignore' \
                "$1" "$2"
          fi
        }
        rcp "$HOME/projects/" "$DEST_DIR/projects"
        rcp "$SRC_DIR/" "$DEST_DIR"
      '';
      serviceConfig = {
        Type = "oneshot";
        Nice = 19;
        IOSchedulingClass = "idle";
        User = config.user.name;
        Group = config.user.group;
      };
    };
    timers.backups = {
      wantedBy = [ "timers.target" ];
      partOf = [ "backups.service" ];
      timerConfig.OnCalendar = "*-*-* 00,12:00:00";
      timerConfig.Persistent = true;
    };
  };
}
