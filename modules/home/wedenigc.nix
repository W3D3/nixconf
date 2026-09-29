{ self, inputs, ... }:
{
  flake.nixosModules.homeWedenigc =
    { ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bkp";
        sharedModules = [
          inputs.plasma-manager.homeModules.plasma-manager
          inputs.meridian.homeModules.default
        ];
        users.wedenigc =
          {
            pkgs,
            lib,
            config,
            ...
          }:
          let
            pico8 = pkgs.stdenv.mkDerivation {
              pname = "pico-8";
              version = "0.2.7";
              src = /home/wedenigc/Documents/pico-8_0.2.7_amd64.zip;
              nativeBuildInputs = with pkgs; [ unzip makeWrapper ];
              unpackPhase = "unzip $src";
              installPhase = ''
                mkdir -p $out/bin $out/share/pico-8
                cp -r pico-8/. $out/share/pico-8/
                chmod +x $out/share/pico-8/pico8
                makeWrapper $out/share/pico-8/pico8 $out/bin/pico8 \
                  --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath (with pkgs; [
                    SDL2
                    alsa-lib
                    libGL
                    libX11
                    libXcursor
                    libXrandr
                    libXinerama
                    libXi
                  ])}
              '';
              meta.mainProgram = "pico8";
            };
            sprout = pkgs.stdenv.mkDerivation {
              pname = "sprout";
              version = "0.8.1";
              src = pkgs.fetchurl {
                url = "https://github.com/simpros/sprout/releases/download/v0.8.1/sprout-linux-x64-musl";
                hash = "sha256-gkwZbzzScHIW9/Q+py4UMdbVb052nYFv17YlgSu17XU=";
              };
              dontUnpack = true;
              installPhase = ''
                mkdir -p $out/bin
                cp $src $out/bin/sprout
                chmod +x $out/bin/sprout
              '';
              meta.mainProgram = "sprout";
            };
          in
          {
            home.username = "wedenigc";
            home.homeDirectory = "/home/wedenigc";
            home.stateVersion = "25.11";

            home.packages = with pkgs; [
              kdePackages.kate
              zed-editor
              gh
              claude-code
              claude-monitor
              fastfetch
              gcc
              gnumake
              binutils
              pkg-config
              autoconf
              automake
              libtool
              cmake
              patch
              discord
              signal-desktop

              obsidian
              spotify
              qbittorrent
              bottles
              pico8
              jetbrains-toolbox

              nchat
              home-assistant-cli
              httpie
              httpie-desktop
              handbrake
              wl-clipboard
              mailspring
              sshfs
              lazysql
              lazydocker
              postgresql
              pgadmin4-desktopmode
              typst
              tigervnc
              htop
              python3Packages.shodan
              uncover
              libreoffice
              inputs.iloader.packages.${pkgs.stdenv.hostPlatform.system}.default
              inputs.hunk.packages.${pkgs.stdenv.hostPlatform.system}.default
              inputs.crit.packages.${pkgs.stdenv.hostPlatform.system}.default
              google-cloud-sdk
              materialgram
              nchat
              n8n
              sprout
            ];

            home.sessionVariables = {
              HASS_SERVER = "https://homeassistant.wedenig.xyz";
            };


            programs.go = {
              enable = true;
              env.GOPATH = "${config.home.homeDirectory}/go";
            };

            home.sessionPath = [ "${config.home.homeDirectory}/go/bin" ];

            programs.plasma.hotkeys.commands."launch-ghostty" = {
              name = "Launch Ghostty";
              key = "Alt+Return";
              command = "${lib.getExe pkgs.ghostty}";
            };

            programs.plasma.shortcuts = {
              kwin."MaximizeActiveWindow" = "Meta+Shift+Up";
            };

            programs.plasma.configFile."kdeglobals"."General"."BrowserApplication" = "com.google.Chrome.desktop";

            programs.plasma.configFile."kcminputrc"."Mouse"."XLbInptMiddleButtonPaste" = false;

            programs.plasma.configFile."touchpadxlibinputrc"."SYNA2393:00 06CB:7A13 Touchpad"."TapButton3" = 0;

            programs.vscode = {
              enable = true;
              package = pkgs.vscode;
              profiles.default.extensions =
                with pkgs.vscode-extensions;
                [
                  reditorsupport.r # R language support + R Markdown
                  reditorsupport.r-syntax # R syntax highlighting
                ]
                ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
                  {
                    name = "quarto";
                    publisher = "quarto";
                    version = "1.116.0";
                    sha256 = "1v0b2442zpmpnfd2dmmzw4d0svq47p1hvs4ckv14gs7fhqvl2303";
                  }
                ];
            };

            programs.home-manager.enable = true;

            services.meridian.enable = true;

            home.activation.createHadesMountPoint = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              mkdir -p $HOME/mnt/hades
            '';

            home.activation.claudeCodePlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              settings="$HOME/.claude/settings.json"
              if [ -f "$settings" ]; then
                tmp=$(${pkgs.jq}/bin/jq '.enabledPlugins["crit@crit"] = true' "$settings")
                echo "$tmp" > "$settings"
              fi
            '';

            systemd.user.mounts."home-wedenigc-mnt-hades" = {
              Unit.Description = "SSHFS mount for hades.local";
              Mount = {
                What = "wedenigc@hades.local:/";
                Where = "/home/wedenigc/mnt/hades";
                Type = "fuse.sshfs";
                Options = "reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,idmap=user,follow_symlinks";
                TimeoutSec = "30";
              };
            };

            systemd.user.automounts."home-wedenigc-mnt-hades" = {
              Unit.Description = "Automount SSHFS hades.local";
              Automount = {
                Where = "/home/wedenigc/mnt/hades";
                TimeoutIdleSec = "600";
              };
              Install.WantedBy = [ "default.target" ];
            };


            xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
              plugin = [
                config.services.meridian.opencode.pluginPath
                "@rynfar/meridian-plugin-opencode-scrub"
              ];
            };
          };
      };
    };
}
