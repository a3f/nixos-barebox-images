{ genImage
, bareboxImage
, rootFS
, imageName  ? "disk"
}:

genImage {
  config = ''
    image ${imageName}.img {
      hdimage {
        partition-table-type = "gpt"
        align = 1M
      }
      partition barebox {
        image = "${bareboxImage}"
        size = 1920K
        in-partition-table = false
        holes = {"(440; 32K)"}
      }
      partition root {
        offset = 3M
        image = "${rootFS}"
        partition-type-uuid = b921b045-1df0-41c3-af44-4c6f280d3fae
      }
    }
  '';
  extraFilesToInstall = [ "${bareboxImage}" ];
}
