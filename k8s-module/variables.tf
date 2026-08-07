variable "availability_zones_count" {
  description = "Number of AZs to be used for cluster nodes"
  type        = number

  validation {
    condition     = var.availability_zones_count >= 1 && var.availability_zones_count <= 3
    error_message = "availability zones must be between 1 and 3"
  }
}

variable "node_count" {
  description = "Number of nodes to create for the cluster"
  type        = number

  validation {
    condition     = var.node_count > 0
    error_message = "nodes of the cluster must be a positive number"
  }

  validation {
    condition     = var.node_count % 2 == 1
    error_message = "Good to have an odd number of nodes"
  }
}

variable "vpc_cidr" {
  description = "CIDR block for cluster VPC"
  type        = string
  default     = "172.35.0.0/16"

  validation {
    condition     = can(cidrsubnet(var.vpc_cidr, 0, 0))
    error_message = "VPC must have a valid CIDR "
  }
}

variable "subnet_cidrs" {
  description = "CIDR blocks for subnets within cluster VPC"
  type        = list(string)
  default     = ["172.35.0.0/20", "172.35.16.0/20", "172.35.32.0/20"]

  validation {
    condition = alltrue([
      for sub_cidr in var.subnet_cidrs : can(cidrsubnet(sub_cidr, 0, 0))
    ])
    error_message = "All subnet CIDR's must be valid"
  }
}

variable "nodes_instance_type" {
  description = "Instance type for cluster EC2 instances"
  type        = string
  default     = "t3.micro"
}

variable "cluster_ssh_key_name" {
  description = "name of the ssh key to create"
  default     = "k8s-cluster-ssh"
}

variable "cluster_ssh_key_path" {
  description = "public ssh key for cluster remote access"
  type        = string
}

variable "my_public_ip" {
  type    = string
  default = "109.242.91.141"
}

variable "hosted_zone_name" {
  description = "The name of the private DNS hosted zone"
  type        = string
  default     = "kubeans.com"
}

variable "nlb_record_name" {
  description = "Name of the A record pointing to the NLB's ip"
  type        = string
  default     = "cluster.kubeans.com"

  validation {
    condition = endswith(
      var.nlb_record_name, join("", [".", var.hosted_zone_name])
    )
    error_message = "This should be a subdomain of the hosted zone"
  }
}