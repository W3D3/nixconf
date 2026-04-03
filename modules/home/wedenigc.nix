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
