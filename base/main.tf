resource "docker_network" "this" {
  count = var.docker_network_name != "" && var.docker_network_driver != "" ? 1 : 0

  name   = var.docker_network_name
  driver = var.docker_network_driver
}

resource "docker_volume" "this" {
  count = length(var.docker_volume) > 0 ? length(var.docker_volume) : 0

  name   = var.docker_volume[count.index].name
  driver = var.docker_volume[count.index].driver
}

resource "docker_image" "this" {
  name         = var.docker_image
  force_remove = var.force_remove_docker_image
}

resource "docker_container" "this" {
  name = var.service_name

  image = docker_image.this.image_id

  command = var.command != [] ? var.command : []
  env     = var.env != [] ? var.env : []

  dynamic "networks_advanced" {
    for_each = var.networks_advanced
    content {
      name         = lookup(networks_advanced.value, "name", null)
      aliases      = lookup(networks_advanced.value, "aliases", null)
      ipv4_address = lookup(networks_advanced.value, "ipv4_address", null)
      ipv6_address = lookup(networks_advanced.value, "ipv6_address", null)
    }
  }

  dynamic "labels" {
    for_each = var.labels
    content {
      label = lookup(labels.value, "label", null)
      value = lookup(labels.value, "value", null)
    }
  }

  dynamic "mounts" {
    for_each = var.mounts
    content {
      source    = lookup(mounts.value, "source", null)
      target    = lookup(mounts.value, "target", null)
      type      = lookup(mounts.value, "type", null)
      read_only = lookup(mounts.value, "read_only", false)
    }
  }

  dynamic "ports" {
    for_each = var.ports
    content {
      internal = lookup(ports.value, "internal", null)
      external = lookup(ports.value, "external", null)
    }
  }

  rm = var.remove_container_after_destroy

  depends_on = [docker_image.this, docker_network.this, docker_volume.this]
}

/*
  Grafana Loki officially supports a Docker plugin that will read logs from Docker containers and ship them to Loki.
  The plugin can be configured to send the logs to a private Loki instance.
*/


/*
resource "null_resource" "loki_driver_plugin" {
  provisioner "local-exec" {
    command = "docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions"
  }
}

// To prevent rewrite your /etc/docker/daemon.json file, check this command before execution
resource "null_resource" "loki_daemon_json" {
  provisioner "local-exec" {
    command = "echo {\"log-driver\": \"loki\", \"log-opts\": { \"loki-url\": \"http://localhost:3100/loki/api/v1/push\", \"loki-batch-size\": \"400\"}} > /etc/docker/daemon.json"
  }
}

resource "null_resource" "restart_docker_engine" {
  provisioner "local-exec" {
    command = "systemctl restart docker"
  }
}
*/
