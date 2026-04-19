{ self, inputs, ... }:
{
  flake.nixosModules.homeWedenigc =
    { ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];
        users.wedenigc =
          { pkgs, lib, ... }:
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
            ];

            programs.git = {
              enable = true;
              settings.commit.gpgsign = true;
              settings.user.signingKey = "8D89757F3C8227BE";
            };

            programs.gpg.enable = true;

            services.gpg-agent = {
              enable = true;
              pinentry.package = pkgs.pinentry-qt;
              defaultCacheTtl = 86400; # 24 hours
              maxCacheTtl = 86400; # 24 hours
            };

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
          };
      };
    };
}
