{ self, inputs, ... }:
{
  flake.nixosConfigurations.glados = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.gladosConfiguration
    ];
  };
}
