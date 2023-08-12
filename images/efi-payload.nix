{ genImage
, dtc
, bareboxImage
, rootFS
, imageName ? "disk"
, payloadName ? "BAREBOX.EFI"
}:

let
  stateDTB = dtc {
    source = ''
      /dts-v1/;
      / {
        aliases {
          state = &state;
        };

        state: nixos_bootstate {
          magic = <0x80321606>;
          compatible = "barebox,state";
          backend-type = "raw";
          backend-storage-type = "direct";
          backend-stridesize = <0x400>;

          nixos {
            #address-cells = <1>;
            #size-cells = <1>;
            boot.timeout@0 {
                reg = <0x0 0x4>;
                type = "uint32";
                default = <3>;
            };
            boot.default@4 {
                reg = <0x4 0x40>;
                type = "string";
            };
          };
        };
      };
    '';
  };
in genImage {
  config = ''
    image ${imageName}.img {
      hdimage {
        partition-table-type = gpt
      }
      partition esp {
        image = "${imageName}-esp.vfat"
        partition-type-uuid = c12a7328-f81f-11d2-ba4b-00a0c93ec93b
        offset = 32768
        bootable = true
      }
      partition root {
        image = "${rootFS}"
        offset = 5M
        partition-type-uuid = b921b045-1df0-41c3-af44-4c6f280d3fae
      }
    }

    image ${imageName}-esp.vfat {
           vfat {
                   file EFI/BOOT/${payloadName} { image = "${bareboxImage}" }
                   file EFI/barebox/state.dtb   { image = "${stateDTB}/oftree.dtb" }
           }
           size = 4M
    }
  '';
  extraFilesToInstall = [ "${bareboxImage}" ];
}
