include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_path_to_repo_root()}//base"
}

dependencies {
  paths = ["${get_path_to_repo_root()}/prometheus/prometheus"]
}

dependency "prometheus" {
  config_path = "${get_path_to_repo_root()}/prometheus/prometheus"

  mock_outputs = {
    docker_network_id = "fake-network"
  }
}

locals {
  service_name = "node-exporter"
}

// This service internally exposes port 9100/tcp

inputs = {
  docker_image              = "prom/node-exporter:latest"
  force_remove_docker_image = true
  service_name              = "${local.service_name}"
  mounts = [
    {
      source    = "/proc"
      target    = "/host/proc"
      type      = "bind"
      read_only = true
    },
    {
      source    = "/sys"
      target    = "/host/sys"
      type      = "bind"
      read_only = true
    },
    {
      source    = "/"
      target    = "/rootfs"
      type      = "bind"
      read_only = true
    }
  ]
  command = [
    "--path.procfs=/host/proc",
    "--path.rootfs=/rootfs",
    "--path.sysfs=/host/sys",
    "--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)"
  ]
  networks_advanced = [
    {
      name = dependency.prometheus.outputs.docker_network_id
    }
  ]
  remove_container_after_destroy = true
}
