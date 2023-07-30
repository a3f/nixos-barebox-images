{ genImage
, bareboxImage
, rootFS
, imageName ? "disk"
}:

genImage {
  config = ''
    image ${imageName}.img {
      hdimage {
        partition-table-type = gpt
      }
      partition boot1 {
        offset = 32k
        size = 2M
        image = "${bareboxImage}"
      }
      partition boot2 {
        offset = 2080k
        size = 2M
        image = "${bareboxImage}"
      }
      partition barebox-environment {
        offset = 4128k
        size = 128k
        image = /dev/null
      }
      partition root {
        image = "${rootFS}"
        offset = 5M
        partition-type-uuid = b921b045-1df0-41c3-af44-4c6f280d3fae
      }
    }

    image ${imageName}.norimg {
      hdimage {
        partition-table-type = none
      }

      partition boot1 {
        offset = 32k
        in-partition-table = false
        image = "${bareboxImage}"
      }
    }
  '';
  extraFilesToInstall = [ "${bareboxImage}" ];
}
