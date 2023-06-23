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
  service_name        = "prometheus"
  docker_network_name = "prometheus"
}

// This service internally exposes port 9090/tcp

inputs = {
  docker_network_name       = "${local.docker_network_name}"
  docker_network_driver     = "bridge"
  docker_image              = "prom/prometheus:latest"
  force_remove_docker_image = true
  service_name              = "${local.service_name}"
  docker_volume = [
    {
      name   = "prometheus_data"
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
      source    = "/com.docker.devenvironments.code/projects/terragrunt-docker/prometheus/prometheus/config"
      target    = "/etc/prometheus"
      type      = "bind"
      read_only = false
    },
    {
      source    = "prometheus_data"
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
    "--config.file=/etc/prometheus/prometheus.yaml",
    "--storage.tsdb.path=/prometheus",
    "--web.console.libraries=/etc/prometheus/console_libraries",
    "--web.console.templates=/etc/prometheus/consoles",
    "--web.enable-lifecycle"
  ]
}
