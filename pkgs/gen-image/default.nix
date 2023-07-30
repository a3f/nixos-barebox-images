{ lib, stdenv, genimage, dosfstools, mtools }:

{ config, extraFilesToInstall ? [] }:
stdenv.mkDerivation {
  name = "image";
  dontUnpack = true;
  dontInstall = true;
  # Performance
  dontPatchELF = true;
  dontStrip = true;
  noAuditTmpdir = true;
  dontPatchShebangs = true;

  nativeBuildInputs = [ genimage dosfstools mtools ];

  inherit config extraFilesToInstall;

  passAsFile = [ "config" ];

  buildPhase = ''
    runHook preBuild

    mkdir -p workdir/genimage-tmp workdir/root output input

    # genimage doesn't like absolute paths here..
    cp $configPath genimage.cfg

    genimage \
        --loglevel 2 \
        --config genimage.cfg \
        --tmppath workdir/genimage-tmp \
        --inputpath input \
        --includepath workdir \
        --outputpath "$out" \
        --rootpath workdir/root

    for file in ${lib.concatStringsSep " " extraFilesToInstall}; do
      cp $file "$out"
    done

    runHook postBuild
  '';
}
