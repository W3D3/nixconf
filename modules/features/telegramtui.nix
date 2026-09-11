{ inputs, ... }:
{
  flake.nixosModules.telegramtui =
    { pkgs, ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager.users.wedenigc =
        { pkgs, ... }:
        let
          telegramtui = pkgs.stdenv.mkDerivation {
            pname = "telegramtui";
            version = "1.0.0";
            src = pkgs.fetchurl {
              url = "https://github.com/k4dy/telegramtui/releases/download/v1.0.0/telegramtui-1.0.0.jar";
              hash = "sha256-pl1/LcX7cpz3B77TteBwmD1NXYvWNIeW/8hPVsSipQc=";
            };
            nativeBuildInputs = [ pkgs.makeWrapper ];
            dontUnpack = true;
            installPhase = ''
              mkdir -p $out/share/telegramtui $out/bin
              cp $src $out/share/telegramtui/telegramtui.jar
              makeWrapper ${pkgs.jre}/bin/java $out/bin/telegramtui \
                --add-flags "-jar $out/share/telegramtui/telegramtui.jar" \
                --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [ pkgs.tdlib ]}
            '';
            meta.mainProgram = "telegramtui";
          };
        in
        {
          home.packages = [ telegramtui ];
        };
    };
}
