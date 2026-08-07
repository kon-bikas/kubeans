module "my_k8s_cluster" {
  source = "./k8s-module"

  availability_zones_count = 3
  node_count               = 5
  nodes_instance_type      = "t3.micro"
  cluster_ssh_key_path     = "~/.ssh/k8s-test-key.pub"
  hosted_zone_name         = "kubeans.com"
  nlb_record_name          = "cluster.kubeans.com"
}

resource "local_file" "ansible_hosts" {
  filename = "${path.module}/hosts.yml"
  content = templatefile("${path.module}/k8s-module/templates/hosts.tftpl", {
    control_plane_ips = module.my_k8s_cluster.control_plane_public_ips
    worker_nodes_ips = module.my_k8s_cluster.worker_nodes_public_ips
    remote_user = "ubuntu"
    ssh_key_path = "~/.ssh/k8s-test-key.pub"
  })

  file_permission = "0644"
}