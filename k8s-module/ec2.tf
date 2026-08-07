locals {
  cp_node_count = floor(var.node_count / 2) + 1
}

resource "aws_key_pair" "cluster_ssh_key" {
  key_name   = var.cluster_ssh_key_name
  public_key = file(var.cluster_ssh_key_path)
}

resource "aws_instance" "control_plane_instance" {
  count = local.cp_node_count

  ami                         = "ami-04df1508c6be5879e"
  instance_type               = var.nodes_instance_type
  key_name                    = var.cluster_ssh_key_name
  subnet_id                   = aws_subnet.k8s-subnets[
    count.index % var.availability_zones_count
  ].id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true

  ebs_block_device {
    device_name = "/dev/sda1"
    iops        = 3000
    volume_type = "gp3"
    volume_size = 8
  }

  tags = {
    Name = "k8s-node-${count.index}"
  }
}

resource "aws_instance" "worker_instance" {
  count = var.node_count - local.cp_node_count

  ami           = "ami-04df1508c6be5879e"
  instance_type = var.nodes_instance_type
  key_name      = var.cluster_ssh_key_name
  subnet_id = aws_subnet.k8s-subnets[
    (count.index + local.cp_node_count) % var.availability_zones_count
  ].id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true

  ebs_block_device {
    device_name = "/dev/sda1"
    iops        = 3000
    volume_type = "gp3"
    volume_size = 8
  }

  tags = {
    Name = "k8s-node-${count.index + local.cp_node_count}"
  }
}
