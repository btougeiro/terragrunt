include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_path_to_repo_root()}//base"
}

dependencies {
  paths = [
    "${get_path_to_repo_root()}/traefik",
    "${get_path_to_repo_root()}/prometheus"
  ]
}

dependency "traefik" {
  config_path = "${get_path_to_repo_root()}/traefik"

  mock_outputs = {
    docker_network_id = "fake-network"
  }
}

dependency "prometheus" {
  config_path = "${get_path_to_repo_root()}/prometheus"

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
      name   = "grafana_provisioning_datasources"
      driver = "local"
    },
    {
      name   = "var_lib_grafana"
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
      source    = "grafana_provisioning_datasources"
      target    = "/etc/grafana/provisioning/datasources"
      type      = "volume"
      read_only = false
    },
    {
      source    = "var_lib_grafana"
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
    }
  ]
  remove_container_after_destroy = true
}
