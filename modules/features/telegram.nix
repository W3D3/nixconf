{ self, inputs, ... }:
{
  flake.nixosModules.telegram =
    { ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      nix.settings = {
        extra-substituters = [
          "https://ayugram-desktop.cachix.org"
          "https://cache.garnix.io"
        ];
        extra-trusted-public-keys = [
          "ayugram-desktop.cachix.org-1:AZ5EqHrJsAKL5YkZYLPEsb1FdD9QlypUwQ0REcJftgA="
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
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
