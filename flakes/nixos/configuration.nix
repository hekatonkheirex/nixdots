{ inputs, config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
    ];

  ## BOOTLOADER ##
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  ## NETWORKING ##
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  ## TIME ZONE ##
  time.timeZone = "America/Asuncion";

  ## LOCALE ##
  i18n.defaultLocale = "en_US.UTF-8";

  ## SOUND ##
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  ## SERVICES ##
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # NextDNS
  services.nextdns = {
    enable = true;
    arguments = [ "-config" "10.0.3.0/24=abcdef" "-cache-size" "10MB" ];
    };

  # CUPS
  services.printing.enable = true;

  # Pipewire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # Enable GVFS
  services.gvfs.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  
  ## USER ##
  users.users.mura = {
    isNormalUser = true;
    description = "Rodrigo Y. Murayama";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      brave
    ];
  };
  users.users.mura.shell = pkgs.zsh;

  ## PACKAGES - SYSTEM WIDE
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
   wget
   git
   curl
   neofetch
   htop
   cifs-utils
   home-manager
   gnome.gnome-tweaks
   gnomeExtensions.appindicator
   gnomeExtensions.caffeine
   gnomeExtensions.dash-to-dock
   orchis-theme
   tela-circle-icon-theme
   nextdns
   gcc
   fzf
  ];

  programs.zsh.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  ## FONTS ##
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
       rubik
       maple-mono
       # Japanese font
       source-han-sans
       font-awesome_4
       font-awesome_5
       font-awesome
       nerdfonts
      ];

  fontconfig = {
    defaultFonts = {
      serif = [ "Rubik" "Source Han Sans" ];
      sansSerif = [ "Rubik" "Source Han Sans" ];
      monospace = [ "Maple Mono" ];
      };
    };
  };

  # Mount windows share
  fileSystems."/mnt/share" = {
    device = "//ROGGL752VW/Dwnlds";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in ["${automount_opts},credentials=/etc/nixos/smb-secrets,uid=1000,gid=100"];
  };

  # QT Applications
  qt.enable = true;
  qt.platformTheme = "gtk2";
  qt.style = "gtk2";

  # Enable ZSH for all users
  # users.defaultUserShell = pkgs.zsh;

  # Enable flakes support
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  nix.optimise.automatic = true;

  system.stateVersion = "23.05";
}
