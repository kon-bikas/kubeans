output "control_plane_private_ips" {
  description = "private ip of cluster control plane nodes"
  value       = aws_instance.control_plane_instance[*].private_ip
}

output "worker_nodes_private_ips" {
  description = "private ip of cluster worker nodes"
  value       = aws_instance.worker_instance[*].private_ip
}

output "control_plane_public_ips" {
  description = "public ip of cluster control plane nodes"
  value       = aws_instance.control_plane_instance[*].public_ip
}

output "worker_nodes_public_ips" {
  description = "public ip of cluster worker nodes"
  value       = aws_instance.worker_instance[*].public_ip
}

output "control_plane_count" {
  description = "The best control plane count for given nodes number, considering etcd quorum"
  value       = floor(var.node_count / 2) + 1
}

output "control_plane_node_name_prefix" {
  description = "Prefix for control plane hostname prefix"
  value = var.control_plane_node_name_prefix
}

output "worker_node_name_prefix" {
  description = "Prefix for control plane hostname prefix"
  value = var.worker_node_name_prefix
}

output "public_lb_dns_name" {
  description = "The domain name of the public nlb"
  value       = aws_lb.public_cluster_nlb.dns_name
}