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
        trusted-public-keys = [ "devenv.cachix.org-1:mItsD5HjznrkU/osAbxyAoatEbrSAYzoqfnBqynzHqs=" ];
      };

      environment.systemPackages = [
        inputs.devenv.packages.${pkgs.stdenv.hostPlatform.system}.devenv
      ];
    };
}
