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
              thunderbird
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

            programs.zsh = {
              enable = true;
              autosuggestion.enable = true;
              syntaxHighlighting.enable = true;
              completionInit = "autoload -U compinit && compinit -u";
              plugins = [
                {
                  name = "nix-shell";
                  src = "${pkgs.zsh-nix-shell}/share/zsh-nix-shell";
                }
                {
                  name = "you-should-use";
                  src = "${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use";
                }
                {
                  name = "fzf-tab";
                  src = "${pkgs.zsh-fzf-tab}/share/zsh-fzf-tab";
                }
              ];
            };

            programs.bat.enable = true;

            programs.zoxide = {
              enable = true;
              enableZshIntegration = true;
            };

            programs.zellij = {
              enable = true;
              settings = {
                theme = "catppuccin-mocha";
                default_mode = "locked";
              };
            };

            programs.eza = {
              enable = true;
              enableZshIntegration = true;
            };

            programs.fzf = {
              enable = true;
              enableZshIntegration = true;
            };

            programs.mise = {
              enable = true;
              enableZshIntegration = true;
            };

            programs.ghostty = {
              enable = true;
              settings.font-family = "JetBrainsMono Nerd Font Mono";
            };

            programs.plasma.hotkeys.commands."launch-ghostty" = {
              name = "Launch Ghostty";
              key = "Alt+Return";
              command = "${lib.getExe pkgs.ghostty}";
            };

            programs.plasma.shortcuts = {
              kwin."MaximizeActiveWindow" = "Meta+Shift+Up";
            };

            programs.starship = {
              enable = true;
              enableZshIntegration = true;
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
