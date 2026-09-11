{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    ayugram-desktop.url = "github:ndfined-crp/ayugram-desktop";

    meridian.url = "github:rynfar/meridian";

    iloader.url = "github:nab138/iloader";

    hunk.url = "github:modem-dev/hunk";

    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    voidarcHypr.url = "git+https://git.voidarc.co.uk/voidarc/hypr";

    hyprgrass = {
      url = "github:horriblename/hyprgrass";
      inputs.hyprland.follows = "voidarcHypr/hyprland";
    };

    otter-launcher = {
      url = "github:kuokuo123/otter-launcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gotify-desktop = {
      url = "github:voidarclabs/gotify-desktop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.voidarc.co.uk/voidarc/quickshell";
      flake = false;
    };

    woomer = {
      url = "github:voidarclabs/woomer";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wshowkeys.url = "github:DreamMaoMao/wshowkeys";

    libfprint-goodix53x5 = {
      url = "github:W3D3/libfprint/85a7ba93daa064dfdba47fdedf29bd9c12168aae";
      flake = false;
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
