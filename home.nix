{ config, pkgs, lib, ... }:

let

  # ------------------------------------------------------------
  # Caelestia Shell (Non-Flake Fetch)
  # ------------------------------------------------------------

  caelestia-src = builtins.fetchGit {
    url = "https://github.com/caelestia-dots/shell.git";
    ref = "main";
  };

  # ------------------------------------------------------------
  # Zen Browser
  # ------------------------------------------------------------

  zen-browser =
    if (pkgs ? zen-browser) then
      pkgs.zen-browser
    else
      pkgs.callPackage ({ fetchurl, appimageTools }:
        appimageTools.wrapType2 {
          pname = "zen-browser";
          version = "latest";
          src = fetchurl {
            url = "https://github.com/zen-browser/desktop/releases/latest/download/zen-x86_64.AppImage";
            hash = "sha256-7SosMpBmwMLR8dPXzBzWZgXTYINJwVSKYsFZJpqYiRQ="; # Updated hash
          };
        }) { };
in
{
  # ------------------------------------------------------------
  # Home Manager identity
  # ------------------------------------------------------------

  home.username = "omodudu";
  home.homeDirectory = "/home/omodudu";
  home.stateVersion = "25.11";
  home.enableNixpkgsReleaseCheck = false;
  home.sessionPath = [
    "/home/omodudu/.local/bin"
  ];


  # ------------------------------------------------------------
  # Portal Backend
  # ------------------------------------------------------------

  xdg.portal = {
    enable = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];

    config = {
      common = {
        default = [
          "hyprland"
          "gtk"
        ];
      };
    };
  };


  # ------------------------------------------------------------
  # Packages
  # ------------------------------------------------------------

  home.packages =
    builtins.filter (p: p != null) (
      (with pkgs; [

        # ---------------------------------------
        # Hyprland dependencies
        # ---------------------------------------

        uwsm
        dart-sass
        swappy
        slurp
        grim
        brightnessctl
        gpu-screen-recorder
        glib


        # ---------------------------------------
        # Caelestia Dependencies
        # ---------------------------------------

        quickshell
        qt6.qtdeclarative
        qt6.qt5compat
        playerctl
        socat


        # ---------------------------------------
        # Hyprland / desktop
        # ---------------------------------------

        hyprland
        hyprlock
        hypridle
        hyprpaper
        hyprpicker
        hyprshot
        hyprsunset


        # ---------------------------------------
        # Applications / utilities
        # ---------------------------------------

        rofimoji
        rofi
        wtype
        bluez
        bluez-tools
        networkmanagerapplet
        networkmanager_dmenu
        yazi
        swayosd
        celluloid
        mpv


        # ---------------------------------------
        # Theming / appearance
        # ---------------------------------------

        matugen
        wlogout
        waybar


        # ---------------------------------------
        # Qt / Wayland
        # ---------------------------------------

        hyprland-qtutils
        qt6.qtwayland


        # ---------------------------------------
        # Wallpaper
        # ---------------------------------------

        awww


        # ---------------------------------------
        # Authentication
        # ---------------------------------------

        hyprpolkitagent


        # ---------------------------------------
        # Notifications
        # ---------------------------------------

        swaynotificationcenter


        # ---------------------------------------
        # Clipboard
        # ---------------------------------------

        wl-clipboard
        cliphist
        wl-clip-persist

      ])

      ++ [

        # ---------------------------------------
        # External Zen Browser package
        # ---------------------------------------

        (if zen-browser ? default then zen-browser.default else zen-browser)

      ]
    );


  # ------------------------------------------------------------
  # SwayOSD
  # ------------------------------------------------------------

  services.swayosd = {
    enable = false;
  };


  # ------------------------------------------------------------
  # Yazi
  # ------------------------------------------------------------

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
  };


  # ------------------------------------------------------------
  # Home Manager dotfiles / Caelestia Shell Setup
  # ------------------------------------------------------------

  home.file.".config/caelestia".source = "${caelestia-src}";


  # ------------------------------------------------------------
  # Environment variables
  # ------------------------------------------------------------

  home.sessionVariables = {

    # Native Wayland for Zen / Firefox

    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";

    # Wayland / Hyprland desktop context

    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";

  };


  # ------------------------------------------------------------
  # Home Manager
  # ------------------------------------------------------------

  programs.home-manager.enable = true;
}
