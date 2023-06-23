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
  service_name = "cadvisor"
}

// This service internally exposes port 8080/tcp

inputs = {
  docker_image              = "gcr.io/cadvisor/cadvisor:latest"
  force_remove_docker_image = true
  service_name              = "${local.service_name}"
  mounts = [
    {
      source    = "/"
      target    = "/rootfs"
      type      = "bind"
      read_only = true
    },
    {
      source    = "/var/run"
      target    = "/var/run"
      type      = "bind"
      read_only = false
    },
    {
      source    = "/sys"
      target    = "/sys"
      type      = "bind"
      read_only = true
    },
    {
      source    = "/var/lib/docker"
      target    = "/var/lib/docker"
      type      = "bind"
      read_only = true
    },
    {
      source    = "/dev/disk"
      target    = "/dev/disk"
      type      = "bind"
      read_only = true
    }
  ]
  networks_advanced = [
    {
      name = dependency.prometheus.outputs.docker_network_id
    }
  ]
  remove_container_after_destroy = true
}
