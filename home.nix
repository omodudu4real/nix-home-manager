{ config, pkgs, ... }:

let
# FIXED: Using the direct binary fetch method which is more reliable for non-flake setups
  zen-browser = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner = "0xc000022070";
    repo = "zen-browser-flake";
    rev = "master";
    sha256 = "sha256-BgkUmlOuFaaZQCnlhXkQ3/Fng65aq00tJQkpoeTn7Mw="; # Nix will fix this for us
  }) { };
in

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "omodudu";
  home.homeDirectory = "/home/omodudu";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.

  # Unnecessary error removal
  home.enableNixpkgsReleaseCheck = false;

  # Portal Backend
  xdg.portal = {
  enable = true;

  extraPortals = with pkgs; [
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
  ];

  config = {
    common = {
      default = [ "hyprland" "gtk" ];
    };
  };
};




  # packages
  home.packages = (with pkgs; [
    wlroots
    mesa
    libdrm
    hyprland
    hyprlock
    hypridle
    hyprpaper
    hyprpicker
    hyprshot
    hyprsunset
    pipewire
    wireplumber
    rofi
    overskride
    bluez
    bluez-tools
    networkmanagerapplet
    networkmanager_dmenu
    yazi
    swayosd
    celluloid
    mpv
    matugen
    wlogout
    waybar
    hyprland-qtutils
    qt6.qtwayland
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    xdg-desktop-portal
    dbus
    awww

    hyprpolkitagent
    swaynotificationcenter
    wl-clipboard
    cliphist
    wl-clip-persist

    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ]) ++ [
    # External community package
    zen-browser.default
  ];



  services.swayosd = {
    enable = false;
  };




  programs.yazi = {
    enable = true;
    enableZshIntegration = true; # This helps with shell navigation
  };



  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/omodudu/etc/profile.d/hm-session-vars.sh
  #

  home.sessionVariables = {
    # Forces Zen (and Firefox) to use native Wayland
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
