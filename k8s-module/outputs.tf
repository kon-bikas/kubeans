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
