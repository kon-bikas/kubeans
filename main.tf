module "my_k8s_cluster" {
  source = "./k8s-module"

  availability_zones_count    = 3
  node_count                  = 5
  control_plane_instance_type = "t2.xlarge"
  worker_instance_type        = "t3.medium"
  cluster_ssh_key_path        = "~/.ssh/k8s-test-key.pub"
  my_public_ip = var.my_public_ip
}

resource "local_file" "ansible_hosts" {
  filename = "${path.module}/hosts.yml"
  content = templatefile("${path.module}/k8s-module/templates/hosts.tftpl", {
    control_plane_ips    = module.my_k8s_cluster.control_plane_public_ips
    worker_nodes_ips     = module.my_k8s_cluster.worker_nodes_public_ips
    control_plane_prefix = module.my_k8s_cluster.control_plane_node_name_prefix
    worker_prefix        = module.my_k8s_cluster.worker_node_name_prefix
    remote_user          = "ubuntu"
    ssh_key_path         = "~/.ssh/k8s-test-key.pub"
  })

  file_permission = "0644"
}


output "cluster_entrypoint_domain_name" {
  description = "Domain name of the public facing cluster load balancer"
  value = module.my_k8s_cluster.public_lb_dns_name
}

variable "my_public_ip" {
  type = string
}