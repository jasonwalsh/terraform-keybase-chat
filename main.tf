terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

locals {
  data = {
    method = "send"
    params = {
      options = {
        channel = {
          name = var.channel
        }
        message = {
          body = var.message
        }
      }
    }
  }

  infile = "/tmp/infile.json"
}

resource "time_static" "created_at" {}

resource "docker_container" "keybase" {
  command = split(" ", "keybase chat api -i ${local.infile}")

  env = [
    "KEYBASE_ALLOW_ROOT=1",
    "KEYBASE_PAPERKEY=${var.paperkey}",
    "KEYBASE_SERVICE=1",
    "KEYBASE_USERNAME=${var.username}"
  ]

  image = "keybaseio/client"
  name  = format("keybase-%s", time_static.created_at.unix)

  upload {
    content = jsonencode(local.data)
    file    = local.infile
  }
}
