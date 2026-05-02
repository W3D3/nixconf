{ self, inputs, ... }:
{
  flake.nixosModules.homeWedenigc =
    { ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        sharedModules = [
          inputs.plasma-manager.homeModules.plasma-manager
          inputs.meridian.homeManagerModules.default
        ];
        users.wedenigc =
          { pkgs, lib, config, ... }:
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

              bambu-studio
              obsidian
              spotify
              steam
              jetbrains-toolbox

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
              go
            ];

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
              plugin = [ config.services.meridian.opencode.pluginPath ];
            };
          };
      };
    };
}
