include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_path_to_repo_root()}//application"
}

dependencies {
  paths = ["${get_path_to_repo_root()}/traefik"]
}

dependency "traefik" {
  config_path = "${get_path_to_repo_root()}/traefik"

  mock_outputs = {
    docker_network_id = "fake-network"
  }
}

locals {
  service_name                 = "portainer"
  docker_volume_portainer_data = "portainer_data"
}

inputs = {
  docker_image              = "portainer/portainer-ce:latest"
  force_remove_docker_image = true
  service_name              = "${local.service_name}"
  docker_volume = [
    {
      name   = "${local.docker_volume_portainer_data}"
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
      value = "9000"
    }
  ]
  mounts = [
    {
      source    = "/var/run/docker.sock"
      target    = "/var/run/docker.sock"
      type      = "bind"
      read_only = true
    },
    {
      source    = "${local.docker_volume_portainer_data}"
      target    = "/data"
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
