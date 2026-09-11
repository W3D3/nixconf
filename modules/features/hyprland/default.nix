{
  moduleWithSystem,
  inputs,
  ...
}:
{
  flake.nixosModules.hyprland = moduleWithSystem (
    {
      self',
      pkgs,
      inputs',
      ...
    }:
    { config, ... }:
    let
      lib = pkgs.lib;
      runtimePkgs = self'.packages.hyprland.passthru.runtimePackages;
      runtimeTarget =
        name: pkg:
        if config.security.wrappers ? ${name} then
          "/run/wrappers/bin/${name}"
        else
          lib.getExe pkg;
    in
    {
      programs.hyprland = {
        enable = true;
        package = self'.packages.hyprland;
      };

      # Hyprland is available as a session in SDDM; select it manually at login.
      # Do not force it as the default to keep KDE as the fallback.
      services.xserver.enable = true;
      security.polkit.enable = true;

      fonts.packages = [ pkgs.nerd-fonts.fira-mono ];

      environment.systemPackages =
        with pkgs;
        [
          gsettings-desktop-schemas
          glib
          bibata-cursors
          (catppuccin-gtk.override {
            variant = "mocha";
            accents = [ "mauve" ];
            tweaks = [ "rimless" ];
            size = "compact";
          })
          (catppuccin-papirus-folders.override {
            flavor = "mocha";
            accent = "mauve";
          })
          playerctl
          pavucontrol
          fsel
          bluetui
        ]
        ++ (with self'.packages; [
          hyprland
          kitty
          waybar
          otter-launcher
          wpaperd
          hyprlock
          way-edges
          wshowkeys
          gotify-desktop
          woomer
          quickshell
        ]);

      environment.variables = {
        XCURSOR_THEME = "Bibata-Modern-Ice";
        XCURSOR_SIZE = "20";
      };

      system.activationScripts.hyprRuntimeEnv = lib.stringAfter [ "specialfs" ] ''
        mkdir -p /run/hypr-runtime-env/bin
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            name: pkg: ''
              ln -sfn ${runtimeTarget name pkg} /run/hypr-runtime-env/bin/${name}
            ''
          ) runtimePkgs
        )}
      '';

      system.activationScripts.hyprConfig =
        let
          pluginFile = pkgs.writeText "plugins.lua" ''
            hl.on("hyprland.start", function ()
            end)
          '';
          runtimeFile = pkgs.writeText "runtime.lua" ''
            hl.on("hyprland.start", function ()
            end)
          '';
        in
        lib.stringAfter [ "specialfs" ] ''
          mkdir -p /run/hypr/config
          rm -rf /run/hypr/config/*
          ln -sfn ${inputs'.voidarcHypr.packages.repo-files}/* /run/hypr/config
          ln -sfn ${pluginFile} /run/hypr/config/plugins.lua
          ln -sfn ${runtimeFile} /run/hypr/config/runtime.lua
        '';
    }
  );

  perSystem =
    {
      self',
      inputs',
      pkgs,
      system,
      ...
    }:
    {
      packages = {
        hyprland = inputs'.voidarcHypr.packages.default.override {
          flags."--config" = "/run/hypr/config/hyprland.lua";
          env."MODULES_ROOT" = "/run/hypr/config/modules";
          env."HYPRLAND_ROOT" = "/run/hypr/config";
          runtimePackages =
            inputs.voidarcHypr.lib.defaultRuntimePkgs.${system}
            // {
              wpaperd = self'.packages.wpaperd;
              kitty = self'.packages.kitty;
              gotify-desktop = self'.packages.gotify-desktop;
              otter-launcher = self'.packages.otter-launcher;
              hyprlock = self'.packages.hyprlock;
              quickshell = self'.packages.quickshell;
              wshowkeys = self'.packages.wshowkeys;
              waybar = self'.packages.waybar;
              way-edges = self'.packages.way-edges;
            };
        };

        kitty =
          let
            fira-mono = pkgs.nerd-fonts.fira-mono;
            fontsConf = pkgs.makeFontsConf { fontDirectories = [ fira-mono ]; };
          in
          inputs.wrapper-modules.wrappers.kitty.wrap {
            inherit pkgs;
            environment = {
              "FONTCONFIG_FILE" = "${fontsConf}";
            };
            font = {
              name = "FiraMono Nerd Font Mono";
              size = 11;
            };
            settings = {
              font_size = 11;
              scrollbar = "never";
              pixel_scroll = false;
              window_padding_width = 9;
              background_opacity = "0.50";
              confirm_os_window_close = 0;
              enable_audio_bell = false;
              cursor_trail = 1;
              cursor_trail_start_threshold = 1;
              cursor_trail_color = "#cba6f7";
              cursor_shape = "beam";
              allow_remote_control = true;
            };
            keybindings = {
              "ctrl+backspace" = "send_text all \\x17";
            };
            themeFile = "Catppuccin-Mocha";
          };

        waybar = inputs.wrapper-modules.wrappers.waybar.wrap {
          inherit pkgs;
          "style.css".path = ./waybar/style.css;
          configFile.content = ''
            {
              "include": [
                "${./waybar/modules.jsonc}"
              ],
              "height": 20,
              "margin": "3 6",
              "reload_style_on_change": true,
              "position": "top",
              "modules-left": [
                "custom/logo",
                "hyprland/workspaces"
              ],
              "modules-center": [
                "mpris"
              ],
              "modules-right": [
                "network",
                "bluetooth",
                "custom/notifs",
                "battery",
                "clock"
              ]
            }
          '';
        };

        quickshell = inputs.wrapper-modules.wrappers.quickshell.wrap {
          inherit pkgs;
          configDir = inputs.quickshell;
          configFile = "${inputs.quickshell}/shell.qml";
        };

        otter-launcher =
          let
            extra-config = ''
              [overlay]
              overlay_cmd = "${pkgs.lib.getExe self'.packages.kitty} +kitten icat --fit height --align left --no-trailing-newline ${./otter-launcher/cat.png}"
              overlay_trimmed_lines = 0
            '';
            final-config = pkgs.writeText "config.toml" ''
              ${extra-config}

              ${builtins.readFile ./otter-launcher/config.toml}
            '';
          in
          inputs.wrapper-modules.lib.wrapPackage (
            { ... }:
            {
              inherit pkgs;
              package = inputs'.otter-launcher.packages.default;
              runtimePkgs = with pkgs; [
                fsel
                bluetui
              ];
              flags = {
                "-c" = final-config;
              };
            }
          );

        wpaperd =
          let
            config-file = builtins.toFile "config.toml" ''
              [any]
              path = "${./wpaperd/wallpapers}"
            '';
          in
          inputs.wrapper-modules.lib.wrapPackage (
            { ... }:
            {
              inherit pkgs;
              package = pkgs.wpaperd;
              flags = {
                "--config" = config-file;
              };
            }
          );

        hyprlock = inputs.wrapper-modules.wrappers.hyprlock.wrap {
          inherit pkgs;
          "hyprlock.conf".content = ''
            source = ${./hyprlock/mocha.conf}

            $accent = $mauve
            $accentAlpha = $mauveAlpha
            $font = FiraMono Nerd Font

            general {
              hide_cursor = true
            }

            background {
              monitor =
              path = screenshot
              blur_passes = 3
              color = rgba(0, 0, 0, 0)
            }

            label {
              monitor =
              text = Layout: $LAYOUT
              color = $text
              font_size = 25
              font_family = $font
              position = 30, -30
              halign = left
              valign = top
            }

            label {
              monitor =
              text = $TIME
              color = $text
              font_size = 90
              font_family = $font
              position = -30, 0
              halign = right
              valign = top
            }

            label {
              monitor =
              text = cmd[update:43200000] date +"%A, %d %B %Y"
              color = $text
              font_size = 25
              font_family = $font
              position = -30, -150
              halign = right
              valign = top
            }

            image {
              path = ${./hyprlock/cat.png}
              size = 240
              border_color = transparent
              rounding = 0
              position = 0, 7px
            }

            image {
              monitor =
              path = $HOME/.face
              size = 100
              border_color = $accent
              position = 0, 75
              halign = center
              valign = center
            }

            input-field {
              monitor =
              size = 300, 60
              outline_thickness = 4
              dots_size = 0.2
              dots_spacing = 0.2
              dots_center = true
              outer_color = $accent
              inner_color = $surface0
              font_color = $text
              fade_on_empty = false
              placeholder_text = <span foreground="##$textAlpha"><i>󰌾 Logged in as </i><span foreground="##$accentAlpha">$USER</span></span>
              hide_input = false
              check_color = $accent
              fail_color = $red
              fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
              capslock_color = $yellow
              position = 0, -47
              halign = center
              valign = center
            }
          '';
        };

        way-edges = inputs.wrapper-modules.lib.wrapPackage (
          { ... }:
          {
            inherit pkgs;
            package = pkgs.way-edges;
            flags = {
              "--config-path" = ./way-edges/config.jsonc;
            };
          }
        );

        wshowkeys = inputs'.wshowkeys.packages.default;
        gotify-desktop = inputs'.gotify-desktop.packages.default;
        woomer = inputs'.woomer.packages.default;
      };
    };
}
