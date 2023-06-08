include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_path_to_repo_root()}//base"
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
  service_name                  = "prometheus"
  docker_volume_prometheus_data = "prometheus_data"
  docker_network_name           = "moniroting"
}

inputs = {
  docker_network_name       = "${local.docker_network_name}"
  docker_network_driver     = "bridge"
  docker_image              = "prom/prometheus:latest"
  force_remove_docker_image = true
  service_name              = "${local.service_name}"
  docker_volume = [
    {
      name   = "${local.docker_volume_prometheus_data}"
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
      value = "9090"
    }
  ]
  mounts = [
    {
      source    = "/etc/prometheus"
      target    = "/etc/prometheus"
      type      = "bind"
      read_only = true
    },
    {
      source    = "${local.docker_volume_prometheus_data}"
      target    = "/prometheus"
      type      = "volume"
      read_only = false
    }
  ]
  networks_advanced = [
    {
      name = dependency.traefik.outputs.docker_network_id
    },
    {
      name = "${local.docker_network_name}"
    }
  ]
  remove_container_after_destroy = true

  command = [
    "--config.file=/etc/prometheus/prometheus.yaml"
  ]
}
