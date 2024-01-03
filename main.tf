terraform {

  required_providers {

    docker = {
      source = "kreuzwerker/docker"
    }
  }
}


# variables

variable "container_name" {
  type        = string
  description = "Name of Container"
  default     = "nodered"
}

variable "int_port" {
  type    = number
  default = 1880

  validation {
    condition     = var.int_port == 1881
    
    error_message = "The internal port for node-red can only be 1880."
  }
}

variable "ext_port" {
  type    = number
  default = 1880

  validation {
    condition     = var.ext_port <= 65535 && var.ext_port > 0
    error_message = "The external port must be in the valid port range 0 - 65535."
  }
}

resource "docker_image" "node_red_image" {

  name = "nodered/node-red:latest"
}

resource "random_string" "random" {
  count = 1
  length = 4
  special = false
  upper = false
}
resource "docker_container" "nodered_container" {
  count = 1
  name  = join( "-",["nodered",random_string.random[count.index].result])
  image = docker_image.node_red_image.name
  ports {
    internal = 1880
    #external = 1880
  }
}


# resource "docker_container" "nodered_container1" {
#   name  = join( "-",["nodered",random_string.random.result])
#   image = docker_image.node_red_image.name
#   ports {
#     internal = 1880
#     #external = 1880
#   }
# }

output "IP-Address"  {
  
  #value = docker_container.nodered_container.network_data
  value = [for i in docker_container.nodered_container[*]: join(":",[i.network_data[0].ip_address,i.ports[0].external])]
  description = "The Ip address of docker container"
}

output "random" {
  
  value = random_string.random
}


#[for ip_address in docker_container.nodered_container[*].network_data[0].ip_address : ip_address]
#[for ports in docker_container.nodered_container[*].ports[0].external: ports]