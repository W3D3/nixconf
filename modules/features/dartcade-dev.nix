{ ... }:
{
  # dartcade dev stack (docker compose, Vite on :5173) at http://dartcade.local
  flake.nixosModules.dartcadeDev =
    { ... }:
    {
      networking.hosts = {
        "127.0.0.1" = [ "dartcade.local" ];
        "::1" = [ "dartcade.local" ];
      };

      # Vite reachable from other machines on the network: the stack's on :5173, a worktree's on :5174
      networking.firewall.allowedTCPPorts = [
        5173
        5174
      ];

      # Plain HTTP on loopback only; Caddy proxies WebSockets (Vite HMR, game /ws) as is
      services.caddy = {
        enable = true;
        virtualHosts."http://dartcade.local".serverAliases = [ "http://dartcade.localhost" ];
        virtualHosts."http://dartcade.local".extraConfig = ''
          bind 127.0.0.1 ::1
          reverse_proxy localhost:5173 {
            # Vite only accepts localhost-style Host headers
            header_up Host localhost:5173
          }
        '';
      };
    };
}
