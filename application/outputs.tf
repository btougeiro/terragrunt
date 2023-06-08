output "docker_network_id" {
  description = "Shows `docker_network` Id."
  value       = var.docker_network_name != "" && var.docker_network_driver != "" ? docker_network.this[0].id : null
}

output "docker_volume_id" {
  description = "Shows `docker_volume` Id."
  value       = length(var.docker_volume) > 0 ? docker_volume.this[*].id : null
}

output "docker_image_id" {
  description = "Shows `docker_image` Id."
  value       = docker_image.this.image_id
}

output "docker_container_id" {
  description = "Shows `docker_container` Id."
  value       = docker_container.this.id
}
