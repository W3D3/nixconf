{ ... }:
{
  # PhotoCraft: open-source, clean-room Photoshop reimplementation in Rust.
  # Not in nixpkgs yet (alpha) — packaged from the upstream x86_64 AppImage.
  flake.nixosModules.photocraft =
    { pkgs, ... }:
    let
      pname = "photocraft";
      version = "0.3.0";

      src = pkgs.fetchurl {
        url = "https://github.com/storytold/photocraft/releases/download/v${version}/photocraft-${version}-linux-x86_64.AppImage";
        hash = "sha256-KeMBH0mlLqJcj+QEJYpsX62wIJTbtAqITWnmuoCOYTY=";
      };

      appimageContents = pkgs.appimageTools.extractType2 { inherit pname version src; };

      photocraft = pkgs.appimageTools.wrapType2 {
        inherit pname version src;

        # The wrapped launcher is named `photocraft`, matching the desktop Exec.
        extraInstallCommands = ''
          install -Dm444 ${appimageContents}/usr/share/applications/ai.storyteller.photocraft.desktop \
            -t $out/share/applications
          cp -r ${appimageContents}/usr/share/icons $out/share/icons
        '';

        meta = {
          description = "Open-source, clean-room reimplementation of Adobe Photoshop in Rust";
          homepage = "https://getartcraft.com/apps/photocraft";
          license = pkgs.lib.licenses.asl20;
          mainProgram = "photocraft";
          platforms = [ "x86_64-linux" ];
        };
      };
    in
    {
      environment.systemPackages = [ photocraft ];
    };
}
