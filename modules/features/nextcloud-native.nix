{ ... }:
{
  # Obiente nc-native — a native (Compose/JVM, jpackage-bundled) Nextcloud client.
  # Upstream ships no flake; this repackages the amd64 .deb and autoPatchelfs the
  # bundled launcher + JRE. Only nightly builds exist, so the URL/hash below is
  # pinned to a specific nightly and must be bumped manually to update.
  flake.nixosModules.nextcloudNative =
    { pkgs, ... }:
    let
      nextcloud-native = pkgs.callPackage (
        {
          lib,
          stdenv,
          fetchurl,
          dpkg,
          autoPatchelfHook,
          makeWrapper,
          alsa-lib,
          brotli,
          libbsd,
          bzip2,
          expat,
          fontconfig,
          freetype,
          libglvnd,
          libmd,
          libpng,
          zlib,
          libsecret,
          gtk3,
          glib,
          pango,
          cairo,
          gdk-pixbuf,
          harfbuzz,
          libx11,
          libxau,
          libxcb,
          libxdmcp,
          libxext,
          libxi,
          libxrender,
          libxtst,
          libxxf86vm,
          libxrandr,
          libxcursor,
          xdg-utils,
        }:
        stdenv.mkDerivation (finalAttrs: {
          pname = "nextcloud-native";
          version = "1.0.4261";

          src = fetchurl {
            url = "https://github.com/Obiente/nc-native/releases/download/nightly-20260826-1246-run1384-068c0a82/nextcloudnative_${finalAttrs.version}_amd64.deb";
            hash = "sha256-AlDswJigtGRj8n+Ht4pyltTYe2VetzTh0pTVkHP+ejg=";
          };

          nativeBuildInputs = [
            dpkg
            autoPatchelfHook
            makeWrapper
          ];

          buildInputs = [
            stdenv.cc.cc.lib
            alsa-lib
            brotli
            libbsd
            bzip2
            expat
            fontconfig
            freetype
            libglvnd
            libmd
            libpng
            zlib
            libsecret
            gtk3
            glib
            pango
            cairo
            gdk-pixbuf
            harfbuzz
            libx11
            libxau
            libxcb
            libxdmcp
            libxext
            libxi
            libxrender
            libxtst
            libxxf86vm
            libxrandr
            libxcursor
          ];

          # skiko / JavaFX dlopen libGL at runtime
          runtimeDependencies = [ libglvnd ];

          unpackPhase = ''
            runHook preUnpack
            dpkg-deb -x $src .
            runHook postUnpack
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out/opt $out/bin $out/share/applications $out/share/pixmaps
            cp -r opt/nextcloudnative $out/opt/nextcloudnative

            ln -s $out/opt/nextcloudnative/bin/NextcloudNative $out/bin/nextcloudnative

            install -Dm644 usr/share/applications/nextcloudnative-NextcloudNative.desktop \
              $out/share/applications/nextcloudnative-NextcloudNative.desktop
            substituteInPlace $out/share/applications/nextcloudnative-NextcloudNative.desktop \
              --replace-fail /opt/nextcloudnative/bin/NextcloudNative $out/bin/nextcloudnative

            install -Dm644 $out/opt/nextcloudnative/lib/NextcloudNative.png \
              $out/share/pixmaps/dev.obiente.nextcloudnative.png

            runHook postInstall
          '';

          # OAuth login opens the browser via xdg-open
          postFixup = ''
            wrapProgram $out/opt/nextcloudnative/bin/NextcloudNative \
              --prefix PATH : ${lib.makeBinPath [ xdg-utils ]}
          '';

          meta = {
            description = "One native client for your complete Nextcloud account";
            homepage = "https://nc-native.obiente.dev/";
            sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
            platforms = [ "x86_64-linux" ];
            mainProgram = "nextcloudnative";
          };
        })
      ) { };
    in
    {
      environment.systemPackages = [ nextcloud-native ];
    };
}
