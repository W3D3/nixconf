{ self, inputs, ... }:
{
  flake.nixosModules.gladosFingerprint =
    { pkgs, lib, ... }:
    {
      # Override the system libfprint with the goodix53x5 branch from GitHub.
      # The source is pinned via the libfprint-goodix53x5 flake input in flake.nix.
      nixpkgs.overlays = [
        (final: prev: {
          libfprint = prev.libfprint.overrideAttrs (old: {
            src = inputs.libfprint-goodix53x5;
            version = "1.94.5-goodix53x5";

            # Drop the 'devdoc' output — we skip gtk-doc generation entirely.
            outputs = [ "out" ];

            # Build only the drivers we need; skip docs and introspection so
            # the build does not require additional dependencies.
            mesonFlags = (builtins.filter (f: !(lib.hasPrefix "-Ddrivers=" f)) (old.mesonFlags or [ ])) ++ [
              "-Ddrivers=goodix53x5,goodixmoc,virtual_image"
              "-Ddoc=false"
              "-Dintrospection=false"
            ];

            # NSS (AES/HMAC crypto) and pixman (image upscaling) are required
            # by the goodix53x5 driver and are not in the upstream buildInputs.
            buildInputs = old.buildInputs ++ [
              prev.nss
              prev.pixman
            ];
          });

          # nixpkgs fprintd 1.94.5 requires libfprint >= 1.94.9, but our
          # libfprint branch is 1.94.5.  Pin fprintd to 1.94.4 which only
          # needs libfprint >= 1.94.0.
          fprintd = prev.fprintd.overrideAttrs (old: {
            version = "1.94.4";
            outputs = [ "out" ];

            src = builtins.fetchTarball {
              url = "https://gitlab.freedesktop.org/libfprint/fprintd/-/archive/v1.94.4/fprintd-v1.94.4.tar.gz";
              sha256 = "sha256:1r8mzivai8lc5aa880y37pjyzqfzci3hlap5s1vl8j33dxvkcs07";
            };

            # 1.94.4 doesn't need -Dsystemd_system_unit_dir in the same way;
            # keep the rest of the flags but strip the gtk_doc one that doesn't exist.
            mesonFlags = builtins.filter (f: !(lib.hasPrefix "-Dgtk_doc=" f)) (old.mesonFlags or [ ]);
          });
        })
      ];

      # fprintd daemon — picks up the overridden libfprint automatically.
      services.fprintd.enable = true;

      # cdc_acm must be present so the driver can claim and detach it at
      # runtime (the sensor exposes itself as a CDC device).
      boot.kernelModules = [ "cdc_acm" ];

      # udev rules — grant seat-local access to the sensor without root.
      services.udev.extraRules = ''
        # Goodix 53x5 fingerprint sensors (27c6:5335 / 27c6:5385 / 27c6:5395)
        SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="5395", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="5335", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="5385", TAG+="uaccess"
      '';

      # PAM — enable fingerprint authentication for login, sudo, and the
      # SDDM / KDE lock-screen unlock prompts.
      security.pam.services = {
        login.fprintAuth = true;
        login.gnupg.enable = true;
        sudo.fprintAuth = true;
        sddm.fprintAuth = true;
        kde-fingerprint.fprintAuth = true;
      };
    };
}
