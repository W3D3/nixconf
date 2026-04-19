{ inputs, ... }:
{
  flake.nixosModules.git =
    { pkgs, ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager.users.wedenigc =
        { pkgs, ... }:
        {
          programs.git = {
            enable = true;
            settings.commit.gpgsign = true;
            settings.user.signingKey = "8D89757F3C8227BE";
          };

          programs.gpg.enable = true;

          services.gpg-agent = {
            enable = true;
            pinentry.package = pkgs.pinentry-qt;
            defaultCacheTtl = 86400; # 24 hours
            maxCacheTtl = 86400; # 24 hours
          };
        };
    };
}
