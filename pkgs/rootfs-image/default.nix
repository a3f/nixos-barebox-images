{ stdenv, zstd, util-linux, src }:

stdenv.mkDerivation {
  name = "rootfs-image";
  inherit src;
  preferLocalBuild = true;
  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  # Performance
  dontPatchELF = true;
  dontStrip = true;
  noAuditTmpdir = true;
  dontPatchShebangs = true;

  nativeBuildInputs = [ zstd util-linux ];

  installPhase = ''
    unzstd $src -o full.img

    sfdisk --dump full.img | (size=0; while IFS= read -r line; do
      set -f ; set -- $line; set +f
      if [ "$1" = "unit:" ] && [ "$2" != "sectors" ]; then exit 1; fi
      if [ "$1" = "sector-size:" ]; then sector_size=''${2%,*}; fi
      if [ "$3" = "start=" ] && [ "$5" = "size=" ]; then
        if [ "''${6%,*}" -ge "$size" ]; then
          start=''${4%,*};
          size=''${6%,*};
        fi
      fi
    done

    if [ -z "$sector_size" ]; then exit 2; fi

    dd if=full.img of=$out bs=$sector_size skip=$start count=$size conv=sparse
  )
  '';
}
