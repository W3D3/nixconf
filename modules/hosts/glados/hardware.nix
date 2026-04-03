{ self, inputs, ... }: {
    flake.nixosModules.gladosHardware = { config, lib, pkgs, modulesPath, ... }:

    {
    imports =
        [ (modulesPath + "/installer/scan/not-detected.nix")
        ];

    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
        { device = "/dev/mapper/luks-50f8b6d4-5b95-423a-a48f-35956cdce8b1";
        fsType = "ext4";
        };

    boot.initrd.luks.devices."luks-50f8b6d4-5b95-423a-a48f-35956cdce8b1".device = "/dev/disk/by-uuid/50f8b6d4-5b95-423a-a48f-35956cdce8b1";

    fileSystems."/boot" =
        { device = "/dev/disk/by-uuid/F83F-6547";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
        };

    swapDevices = [ ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };

}
