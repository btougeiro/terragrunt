include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_path_to_repo_root()}//base"
}

locals {
  service_name        = "traefik"
  docker_network_name = "reverse-proxy"
}

// This service internally exposes port 80/tcp

inputs = {
  docker_network_name       = "${local.docker_network_name}"
  docker_network_driver     = "bridge"
  docker_image              = "traefik:v2.10"
  force_remove_docker_image = true
  service_name              = "${local.service_name}"
  labels = [
    {
      label = "traefik.http.routers.${local.service_name}.rule"
      value = "Host(`${local.service_name}.docker.localhost`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))"
    },
    {
      label = "traefik.http.services.${local.service_name}.loadbalancer.server.port"
      value = "80"
    },
    {
      label = "traefik.http.routers.${local.service_name}.service"
      value = "api@internal"
    }
  ]
  ports = [
    {
      internal = 80
      external = 80
    }
  ]
  mounts = [
    {
      source    = "/var/run/docker.sock"
      target    = "/var/run/docker.sock"
      type      = "bind"
      read_only = true
    }
  ]
  remove_container_after_destroy = true
  command = [
    "--api.dashboard=true",
    "--providers.docker=true",
    "--entrypoints.web.address=:80"
  ]
  env = ["TZ=Europe/Lison"]
  networks_advanced = [
    {
      name = "${local.docker_network_name}"
    }
  ]
}
