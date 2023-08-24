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
  service_name        = "promtail"
  config_mount_source = "/opt/terragrunt-observability-docker/grafana/promtail/config"
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
      source    = local.config_mount_source
      target    = "/etc/promtail"
      type      = "bind"
      read_only = false
    }
  ]
  networks_advanced = [
    {
      name = dependency.loki.outputs.docker_network_id
    }
  ]
  remove_container_after_destroy = true

  command = [
    "--config.file=/etc/promtail/promtail.yaml"
  ]
}
