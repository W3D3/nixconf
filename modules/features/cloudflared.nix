{ ... }:
{
  flake.nixosModules.cloudflared =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.cloudflared ];
    };
}
