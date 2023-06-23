include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_path_to_repo_root()}//base"
}

dependencies {
  paths = ["${get_path_to_repo_root()}/grafana/loki"]
}

dependency "loki" {
  config_path = "${get_path_to_repo_root()}/grafana/loki"

  mock_outputs = {
    docker_network_id = "fake-network"
  }
}

locals {
  service_name = "promtail"
}

inputs = {
  docker_image              = "grafana/promtail:latest"
  force_remove_docker_image = true
  service_name              = "${local.service_name}"
  mounts = [
    {
      source    = "/var/log"
      target    = "/var/log"
      type      = "bind"
      read_only = true
    },
    {
      source    = "/com.docker.devenvironments.code/projects/terragrunt-docker/grafana/promtail/config"
      target    = "/etc/promtail"
      type      = "bind"
      read_only = false
    }
  ]
  networks_advanced = [
    {
      name = dependency.prometheus.outputs.docker_network_id
    }
  ]
  remove_container_after_destroy = true

  command = [
    "--config.file=/etc/promtail/promtail.yaml"
  ]
}
