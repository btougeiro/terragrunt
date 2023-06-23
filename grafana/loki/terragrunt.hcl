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
  service_name        = "loki"
  docker_network_name = "loki"
}

// This service internally exposes port 3100/tcp. You don't need to specify the port because traefik will do it for you.
// Instead of using http://loki.docker.localhost:3100, you should use http://loki.docker.localhost.
// To check if the service is running you can access the following URL: http://loki.docker.localhost/metrics.
// You can also test for readiness with the following URL: http://loki.docker.localhost/ready.

inputs = {
  docker_network_name       = "${local.docker_network_name}"
  docker_network_driver     = "bridge"
  docker_image              = "grafana/loki:latest"
  force_remove_docker_image = true
  service_name              = "${local.service_name}"
  labels = [
    {
      label = "traefik.http.routers.${local.service_name}.rule"
      value = "Host(`${local.service_name}.docker.localhost`)"
    },
    {
      label = "traefik.http.services.${local.service_name}.loadbalancer.server.port"
      value = "3100"
    }
  ]
  mounts = [
    {
      source    = "/com.docker.devenvironments.code/projects/terragrunt-docker/grafana/loki/config"
      target    = "/etc/loki"
      type      = "bind"
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
    "--config.file=/etc/loki/loki.yaml"
  ]
}
