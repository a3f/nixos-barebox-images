{ pkgs ? import <nixpkgs> {} }:

let
  unfreePkgs = import pkgs.path {
    config.allowUnfree = true;
    inherit (pkgs) system;
  };
  aarch64Pkgs = unfreePkgs.pkgsCross.aarch64-multiplatform;

  genImage = pkgs.callPackage ./pkgs/gen-image {};
  dtc = pkgs.callPackage ./pkgs/device-tree {};

  # rootFS
  aarch64Image = pkgs.callPackage ./pkgs/aarch64-image {};

  # Image configs
  rockchip = bareboxImage: pkgs.callPackage ./images/rockchip.nix {
    inherit genImage bareboxImage; rootFS = aarch64Image;
  };
  imx8m = bareboxImage: pkgs.callPackage ./images/imx8m.nix {
    inherit genImage bareboxImage; rootFS = aarch64Image;
  };
  };

  # Bootloaders
  bb-armv7    = aarch64Pkgs.bareboxARMv7;
  bb-armv8    = aarch64Pkgs.bareboxARMv8;
in {
  rock3a          = rockchip "${bb-armv8}/barebox-rock3a.img";

  imx8mn-evk      = imx8m    "${bb-armv8}/barebox-nxp-imx8mn-evk.img";
  imx8mm-evk      = imx8m    "${bb-armv8}/barebox-nxp-imx8mm-evk.img";
  imx8mp-evk      = imx8m    "${bb-armv8}/barebox-nxp-imx8mp-evk.img";

}
