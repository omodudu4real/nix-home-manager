{ config, pkgs, lib, ... }:

let

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
            hash = "sha256-NJcEhxUi4AhfO1BdYpAJSQ7vs/Bu5nqH6hBtyxOVzP4=";
          };
        }) { };


  # ------------------------------------------------------------
  # Fix dlib for Python 3.14 / Howdy
  #
  # Wipe out patches via custom patchPhase.
  # ------------------------------------------------------------

  python3Packages-fixed =
    pkgs.python3Packages.overrideScope
      (python-final: python-prev: {

        dlib =
          if (python-prev ? dlib) then
            python-prev.dlib.overrideAttrs (_oldAttrs: {
              patches = [ ];
              cmakeFlags = [ ];
              patchPhase = ''
                runHook prePatch
                echo "Skipping dlib patches..."
                runHook postPatch
              '';
            })
          else
            null;


        # ------------------------------------------------------------
        # Fix face-recognition so it uses our fixed dlib
        # ------------------------------------------------------------

        face-recognition =
          if (python-prev ? face-recognition) then
            python-prev.face-recognition.overrideAttrs
              (oldAttrs: {
                propagatedBuildInputs =
                  builtins.map
                    (
                      dep:
                        if (builtins.baseNameOf (toString dep)) == "dlib"
                        then python-final.dlib
                        else dep
                    )
                    (oldAttrs.propagatedBuildInputs or [ ]);

                buildInputs =
                  builtins.map
                    (
                      dep:
                        if (builtins.baseNameOf (toString dep)) == "dlib"
                        then python-final.dlib
                        else dep
                    )
                    (oldAttrs.buildInputs or [ ]);
              })
          else
            null;


        # ------------------------------------------------------------
        # Make OpenCV available to Howdy as Python cv2
        # ------------------------------------------------------------

        opencv4 = python-prev.opencv4;
      });


  # ------------------------------------------------------------
  # Howdy Python dependencies
  #
  # Howdy's pythonDeps directly contains:
  #
  #   dlib
  #   elevate
  #   face-recognition
  #   keyboard
  #   opencv4Full
  #   pycairo
  #   pygobject3
  #
  # Replace only dlib and face-recognition with our fixed versions.
  # ------------------------------------------------------------

  howdy-python-deps =
    builtins.map
      (
        dep:
          if dep == "dlib"
          then
            python3Packages-fixed.dlib
          else if dep == "face-recognition"
          then
            python3Packages-fixed.face-recognition
          else if dep == "opencv4Full"
          then
            python3Packages-fixed.opencv4
          else
            dep
      )
      pkgs.howdy.pythonDeps;


  # ------------------------------------------------------------
  # Python environment required by Howdy
  # ------------------------------------------------------------

  howdy-python-env =
    python3Packages-fixed.python.withPackages
      (_: howdy-python-deps);


  # ------------------------------------------------------------
  # Howdy using the fixed Python environment
  # ------------------------------------------------------------

  howdy-fixed =
    if (pkgs ? howdy) then
      pkgs.howdy.overrideAttrs
        (oldAttrs: {
          pythonDeps = howdy-python-deps;
          pythonEnv = howdy-python-env;

          mesonFlags =
            builtins.map
              (
                flag:
                  if builtins.match "^-Dpython_path=.*" flag != null
                  then
                    "-Dpython_path=${howdy-python-env}/bin/python"
                  else
                    flag
              )
              (oldAttrs.mesonFlags or [ ]);
        })
    else
      null;


  # ------------------------------------------------------------
  # Caelestia shell with Howdy PAM integration
  # ------------------------------------------------------------

  caelestia-shell-fixed =
    if (pkgs ? caelestia-shell) then
      pkgs.caelestia-shell.overrideAttrs
        (oldAttrs: {
          src = /home/omodudu/.local/src/caelestia/shell;

          patches = [ ];

          postPatch = ''
            true
          '';

          postInstall =
            (oldAttrs.postInstall or "")
            + (
              if howdy-fixed != null then
                ''
                  install -Dm644 /dev/stdin \
                    $out/share/caelestia-shell/assets/pam.d/howdy <<EOF
                  #%PAM-1.0
                  auth required ${howdy-fixed}/lib/security/pam_howdy.so max-tries=1
                  EOF
                ''
              else
                ""
            );
        })
    else
      null;

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
        # Caelestia
        # ---------------------------------------

        caelestia-shell-fixed
        (if pkgs ? caelestia-cli then caelestia-cli else null)


        # ---------------------------------------
        # Caelestia / Hyprland dependencies
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
        # Eww / Elkowar's Wacky Widget
        # ---------------------------------------

        eww


        # ---------------------------------------
        # Hyprland / desktop
        # ---------------------------------------

        howdy-fixed
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
  # Home Manager dotfiles
  # ------------------------------------------------------------

  home.file = { };


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
