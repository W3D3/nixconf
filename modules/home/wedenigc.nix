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
          inputs.meridian.homeManagerModules.default
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
              pico8
              jetbrains-toolbox

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
            ];

            home.sessionVariables = {
              HASS_SERVER = "https://homeassistant.wedenig.xyz";
            };

            programs.zsh.initContent = ''
              export HASS_TOKEN=$(op read "op://Personal/gdtwwssmzb7z6eswd5rf7ufhde/apitoken" 2>/dev/null)
            '';

            programs.go = {
              enable = true;
              env.GOPATH = "${config.home.homeDirectory}/go";
            };

            home.sessionPath = [ "${config.home.homeDirectory}/go/bin" ];

            programs.direnv = {
              enable = true;
              nix-direnv.enable = true;
            };

            programs.plasma.hotkeys.commands."launch-ghostty" = {
              name = "Launch Ghostty";
              key = "Alt+Return";
              command = "${lib.getExe pkgs.ghostty}";
            };

            programs.plasma.shortcuts = {
              kwin."MaximizeActiveWindow" = "Meta+Shift+Up";
            };

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
