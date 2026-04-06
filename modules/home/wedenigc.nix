{ self, inputs, ... }:
{
  flake.nixosModules.homeWedenigc =
    { ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.wedenigc =
          { pkgs, ... }:
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
            ];

            programs.zsh = {
              enable = true;
              autosuggestion.enable = true;
              syntaxHighlighting.enable = true;
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
                  name = "zsh-vi-mode";
                  src = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
                }
              ];
            };

            programs.bat.enable = true;

            programs.zoxide = {
              enable = true;
              enableZshIntegration = true;
            };

            programs.zellij.enable = true;

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

            programs.starship = {
              enable = true;
              enableZshIntegration = true;
            };

            programs.home-manager.enable = true;
          };
      };
    };
}
