{ inputs, ... }:
{
  flake.nixosModules.shell =
    { pkgs, ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager.users.wedenigc =
        { pkgs, lib, ... }:
        {
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

          programs.starship = {
            enable = true;
            enableZshIntegration = true;
          };
        };
    };
}
