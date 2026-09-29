{ inputs, ... }:
{
  flake.nixosModules.devenv =
    { pkgs, ... }:
    {
      nix.settings = {
        trusted-users = [
          "root"
          "wedenigc"
        ];
        substituters = [ "https://devenv.cachix.org" ];
        trusted-public-keys = [ "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" ];
      };

      environment.systemPackages = [
        inputs.devenv.packages.${pkgs.stdenv.hostPlatform.system}.devenv
      ];
    };
}
