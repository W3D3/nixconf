{ inputs, ... }:
{
  flake.nixosModules.mail =
    { pkgs, ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager.users.wedenigc =
        { pkgs, ... }:
        {
          programs.thunderbird = {
            enable = true;
            profiles.default = {
              isDefault = true;
            };
          };

          accounts.email.accounts.gmail = {
            primary = true;
            address = "wedenigc@gmail.com";
            userName = "wedenigc@gmail.com";
            realName = "Christoph Wedenig";
            thunderbird = {
              enable = true;
              profiles = [ "default" ];
            };
            imap = {
              host = "imap.gmail.com";
              port = 993;
              tls.enable = true;
            };
            smtp = {
              host = "smtp.gmail.com";
              port = 465;
              tls.enable = true;
            };
          };

          accounts.email.accounts.aau = {
            address = "christoph.wedenig@aau.at";
            realName = "Christoph Wedenig";
            userName = "christoph.wedenig@aau.at";
            thunderbird = {
              enable = true;
              profiles = [ "default" ];
            };
            imap = {
              host = "mail.aau.at";
              port = 993;
              tls.enable = true;
            };
            smtp = {
              host = "mail.aau.at";
              port = 587;
              tls = {
                enable = true;
                useStartTls = true;
              };
            };
          };

          # XPI files — install once manually via Thunderbird Add-ons Manager
          # See README for instructions
          home.file.".local/share/thunderbird-extensions/thunderai.xpi" = {
            source =
              pkgs.fetchFirefoxAddon {
                name = "thunderai";
                url = "https://github.com/micz/ThunderAI/releases/download/v4.0.6/thunderai-v4.0.6.xpi";
                sha256 = "sha256-86wuKdsFUTcIpg7k6XAbwKbZnopjT24pmrlCV46OOok=";
                fixedExtid = "thunderai@micz.it";
              }
              + "/thunderai@micz.it.xpi";
          };

          # thunderbird-mcp bridge + extension
          home.file.".local/share/thunderbird-mcp/mcp-bridge.cjs" = {
            source = pkgs.fetchurl {
              url = "https://raw.githubusercontent.com/TKasperczyk/thunderbird-mcp/v0.4.0/mcp-bridge.cjs";
              sha256 = "1bn35gsi67g9scsiklqkdqzh1cnjfgx8fnrpa1v86fkn3f37i54z";
            };
          };
          home.file.".local/share/thunderbird-mcp/thunderbird-mcp.xpi" = {
            source =
              pkgs.fetchFirefoxAddon {
                name = "thunderbird-mcp";
                url = "https://github.com/TKasperczyk/thunderbird-mcp/releases/download/v0.4.0/thunderbird-mcp.xpi";
                sha256 = "sha256-diry9nLRir6o8X99E3nRgorZufeGsSGKqE77UGy4lbw=";
                fixedExtid = "thunderbird-mcp@tkasperczyk.dev";
              }
              + "/thunderbird-mcp@tkasperczyk.dev.xpi";
          };

          # Claude Code MCP config
          home.file.".claude.json".text = builtins.toJSON {
            mcpServers = {
              thunderbird-mail = {
                command = "${pkgs.nodejs_24}/bin/node";
                args = [ "/home/wedenigc/.local/share/thunderbird-mcp/mcp-bridge.cjs" ];
              };
            };
          };
        };
    };
}
