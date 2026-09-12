{ ... }:
{
  flake.nixosModules.iosDevices =
    { pkgs, ... }:
    {
      services.usbmuxd.enable = true;

      environment.systemPackages = with pkgs; [
        libimobiledevice
        ideviceinstaller
        idevicerestore
      ];
    };
}
