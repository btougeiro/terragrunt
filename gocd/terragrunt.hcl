include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "..//application"
}

dependencies {
  paths = ["../traefik"]
}

dependency "traefik" {
  config_path = "../traefik"

  mock_outputs = {
    docker_network_id = "fake-network"
  }
}

locals {
  service_name            = "gocd"
  docker_volume_gocd_home = "gocd_home"
  docker_volume_gocd_data = "gocd_data"
}

inputs = {
  docker_image              = "gocd/gocd-server:v23.1.0"
  force_remove_docker_image = true
  service_name              = "${local.service_name}"
  docker_volume = [
    {
      name   = "${local.docker_volume_gocd_home}"
      driver = "local"
    },
    {
      name   = "${local.docker_volume_gocd_data}"
      driver = "local"
    }
  ]
  labels = [
    {
      label = "traefik.http.routers.${local.service_name}.rule"
      value = "Host(`${local.service_name}.docker.localhost`)"
    },
    {
      label = "traefik.http.services.${local.service_name}.loadbalancer.server.port"
      value = "8153"
    }
  ]
  mounts = [
    {
      source    = "${local.docker_volume_gocd_home}"
      target    = "/home/go"
      type      = "volume"
      read_only = false
    },
    {
      source    = "${local.docker_volume_gocd_data}"
      target    = "/godata"
      type      = "volume"
      read_only = false
    }
  ]
  networks_advanced = [
    {
      name = dependency.traefik.outputs.docker_network_id
    }
  ]
  remove_container_after_destroy = true
}
