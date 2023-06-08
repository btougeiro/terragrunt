variable "docker_network_name" {
  type        = string
  description = "(Optional) Either set or not a docker network name."
  default     = ""
}

variable "docker_network_driver" {
  type        = string
  description = "(Optional) Either set or not a docker network driver."
  default     = ""
}

variable "docker_volume" {
  type        = list(map(string))
  description = "(Optional) Either set or not a docker volume."
  default     = []
}

variable "docker_image" {
  type        = string
  description = "(Required) Defines docker image to a service."
  default     = ""
}

variable "force_remove_docker_image" {
  type        = bool
  description = "(Optional) Either remove or not docker image after `terraform destroy`."
  default     = false
}

variable "service_name" {
  type        = string
  description = "(Required) Defines container service name."
  default     = ""
}

variable "labels" {
  type        = list(map(string))
  description = "(Optional) Defines labels to configure container with Traefik."
  default     = []
}

variable "ports" {
  type        = list(map(string))
  description = "(Optional) Defines ports to configure to docker container."
  default     = []
}

variable "mounts" {
  type        = list(map(string))
  description = "(Optional) Defines mount point to configure container persistent data."
  default     = []
}

variable "remove_container_after_destroy" {
  type        = bool
  description = "(Optional) Either remove or not docker container after `terraform destroy`."
  default     = false
}

variable "command" {
  type        = list(string)
  description = "(Optional) Either set or not a command to a docker container."
  default     = []
}

variable "env" {
  type        = list(string)
  description = "(Optional) Either set or not Linux environment variables to a docker container."
  default     = []
}

variable "networks_advanced" {
  type        = list(any)
  description = "(Optional) Either set or not Network Configuration to a docker container."
  default     = []
}
