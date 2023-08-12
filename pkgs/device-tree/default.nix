{ lib, stdenv, dtc }:

{ source }:

stdenv.mkDerivation {
  name = "device-tree";
  dontUnpack = true;
  dontInstall = true;
  # Performance
  dontPatchELF = true;
  dontStrip = true;
  noAuditTmpdir = true;
  dontPatchShebangs = true;

  nativeBuildInputs = [
    dtc
  ];

  inherit source;

  passAsFile = [ "source" ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out

    dtc -I dts -O dtb $sourcePath > $out/oftree.dtb

    runHook postBuild
  '';
}
