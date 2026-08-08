{ self, inputs, ... }:
{
  flake.nixosModules.telegram =
    { ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      nix.settings = {
        extra-substituters = [
          "https://ayugram-desktop.cachix.org"
        ];
        extra-trusted-public-keys = [
          "ayugram-desktop.cachix.org-1:AZ5EqHrJsAKL5YkZYLPEsb1FdD9QlypUwQ0REcJftgA="
        ];
      };

      home-manager.users.wedenigc =
        { pkgs, ... }:
        {
          home.packages = [
            inputs.ayugram-desktop.packages.${pkgs.stdenv.hostPlatform.system}.default
          ];
        };
    };
}
