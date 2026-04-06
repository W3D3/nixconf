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
        sudo.fprintAuth = true;
        sddm.fprintAuth = true;
        kde-fingerprint.fprintAuth = true;
      };
    };
}
