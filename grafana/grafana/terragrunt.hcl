include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_path_to_repo_root()}//base"
}

dependencies {
  paths = [
    "${get_path_to_repo_root()}/traefik",
    "${get_path_to_repo_root()}/prometheus/prometheus",
    "${get_path_to_repo_root()}/grafana/loki"
  ]
}

dependency "traefik" {
  config_path = "${get_path_to_repo_root()}/traefik"

  mock_outputs = {
    docker_network_id = "fake-network"
  }
}

dependency "prometheus" {
  config_path = "${get_path_to_repo_root()}/prometheus/prometheus"

  mock_outputs = {
    docker_network_id = "fake-network"
  }
}

dependency "loki" {
  config_path = "${get_path_to_repo_root()}/grafana/loki"

  mock_outputs = {
    docker_network_id = "fake-network"
  }
}

// This service internally exposes port 3000/tcp

locals {
  service_name = "grafana"
}

inputs = {
  docker_image              = "grafana/grafana:latest"
  force_remove_docker_image = true
  service_name              = "${local.service_name}"
  docker_volume = [
    {
      name   = "${local.service_name}-data"
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
      value = "3000"
    }
  ]
  mounts = [
    {
      source    = "${local.service_name}-data"
      target    = "/var/lib/grafana"
      type      = "volume"
      read_only = false
    }
  ]
  networks_advanced = [
    {
      name = dependency.traefik.outputs.docker_network_id
    },
    {
      name = dependency.prometheus.outputs.docker_network_id
    },
    {
      name = dependency.loki.outputs.docker_network_id
    }
  ]
  remove_container_after_destroy = true
}
