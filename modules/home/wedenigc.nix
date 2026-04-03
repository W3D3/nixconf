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
              ghostty
              claude-code
              fastfetch
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
                {
                  name = "zsh-z";
                  src = "${pkgs.zsh-z}/share/zsh-z";
                }
              ];
            };

            programs.starship = {
              enable = true;
              enableZshIntegration = true;
              configFile = ./starship.toml;
            };

            programs.home-manager.enable = true;
          };
      };
    };
}
