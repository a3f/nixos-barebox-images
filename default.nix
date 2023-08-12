{ pkgs ? import <nixpkgs> {} }:

let
  unfreePkgs = import pkgs.path {
    config.allowUnfree = true;
    inherit (pkgs) system;
  };
  fetchurl = import <nix/fetchurl.nix>;
  aarch64Pkgs = unfreePkgs.pkgsCross.aarch64-multiplatform;

  genImage = pkgs.callPackage ./pkgs/gen-image {};
  dtc = pkgs.callPackage ./pkgs/device-tree {};

  # rootFS
  aarch64Image = pkgs.callPackage ./pkgs/rootfs-image { src = fetchurl {
    url = "https://hydra.nixos.org/build/231606673/download/1/nixos-sd-image-23.05.2753.3fe694c4156b-aarch64-linux.img.zst";
    sha256 = "sha256-HID6G2Y8kndvcr1WuX/BW8qQqSpbmRCn00n9c8i/n3I=";
  }; };

  # TODO replace by actual image
  amd64Image = pkgs.callPackage ./pkgs/rootfs-image { src = fetchurl {
    url = "https://hydra.nixos.org/build/231606673/download/1/nixos-sd-image-23.05.2753.3fe694c4156b-aarch64-linux.img.zst";
    sha256 = "sha256-HID6G2Y8kndvcr1WuX/BW8qQqSpbmRCn00n9c8i/n3I=";
  }; };

  # Image configs
  rockchip = bareboxImage: pkgs.callPackage ./images/rockchip.nix {
    inherit genImage bareboxImage; rootFS = aarch64Image;
  };
  imx8m = bareboxImage: pkgs.callPackage ./images/imx8m.nix {
    inherit genImage bareboxImage; rootFS = aarch64Image;
  };
  efi = bareboxImage: payloadName: rootFS: pkgs.callPackage ./images/efi-payload.nix {
    inherit genImage bareboxImage rootFS dtc;
  };

  # Bootloaders
  bb-armv7    = aarch64Pkgs.bareboxARMv7;
  bb-armv8    = aarch64Pkgs.bareboxARMv8;
  bb-amd64    = pkgs.bareboxEfiPayloadX86;
in {
  rock3a          = rockchip "${bb-armv8}/barebox-rock3a.img";

  imx8mn-evk      = imx8m    "${bb-armv8}/barebox-nxp-imx8mn-evk.img";
  imx8mm-evk      = imx8m    "${bb-armv8}/barebox-nxp-imx8mm-evk.img";
  imx8mp-evk      = imx8m    "${bb-armv8}/barebox-nxp-imx8mp-evk.img";

  amd64-efi       = efi      "${bb-amd64}/barebox.efi" "BOOTx64.EFI" amd64Image;
}
