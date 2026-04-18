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

            programs.zsh = {
              enable = true;
              autosuggestion.enable = true;
              syntaxHighlighting.enable = true;
              completionInit = "autoload -U compinit && compinit -u";
              shellAliases = {
                clip = "wl-copy";
              };
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

            programs.thunderbird = {
              enable = true;
              profiles.default = {
                isDefault = true;
                extensions = [
                  (pkgs.fetchFirefoxAddon {
                    name = "thunderai";
                    url = "https://github.com/micz/ThunderAI/releases/download/v4.0.6/thunderai-v4.0.6.xpi";
                    sha256 = "sha256-86wuKdsFUTcIpg7k6XAbwKbZnopjT24pmrlCV46OOok=";
                    fixedExtid = "thunderai@micz.it";
                  })
                  (pkgs.fetchFirefoxAddon {
                    name = "thunderbird-mcp";
                    url = "https://github.com/TKasperczyk/thunderbird-mcp/releases/download/v0.4.0/thunderbird-mcp.xpi";
                    sha256 = "sha256-diry9nLRir6o8X99E3nRgorZufeGsSGKqE77UGy4lbw=";
                    fixedExtid = "thunderbird-mcp@tkasperczyk.dev";
                  })
                ];
              };
            };

            accounts.email.accounts.gmail = {
              primary = true;
              address = "wedenigc@gmail.com";
              userName = "wedenigc@gmail.com";
              realName = "Christoph Wedenig";
              thunderbird = {
                enable = true;
                profiles = [ "default" ];
              };
              imap = {
                host = "imap.gmail.com";
                port = 993;
                tls.enable = true;
              };
              smtp = {
                host = "smtp.gmail.com";
                port = 465;
                tls.enable = true;
              };
            };

            accounts.email.accounts.aau = {
              address = "christoph.wedenig@aau.at";
              realName = "Christoph Wedenig";
              userName = "christoph.wedenig@aau.at";
              thunderbird = {
                enable = true;
                profiles = [ "default" ];
              };
              imap = {
                host = "mail.aau.at";
                port = 993;
                tls.enable = true;
              };
              smtp = {
                host = "mail.aau.at";
                port = 587;
                tls = {
                  enable = true;
                  useStartTls = true;
                };
              };
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

            # thunderbird-mcp bridge script
            home.file.".local/share/thunderbird-mcp/mcp-bridge.cjs" = {
              source = pkgs.fetchurl {
                url = "https://raw.githubusercontent.com/TKasperczyk/thunderbird-mcp/v0.4.0/mcp-bridge.cjs";
                sha256 = "1bn35gsi67g9scsiklqkdqzh1cnjfgx8fnrpa1v86fkn3f37i54z";
              };
            };

            # Claude Code MCP config
            home.file.".claude.json".text = builtins.toJSON {
              mcpServers = {
                thunderbird-mail = {
                  command = "${pkgs.nodejs}/bin/node";
                  args = [ "/home/wedenigc/.local/share/thunderbird-mcp/mcp-bridge.cjs" ];
                };
              };
            };

            programs.home-manager.enable = true;
          };
      };
    };
}
