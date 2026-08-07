resource "aws_security_group" "k8s_sg" {
  name   = "k8s_sg"
  vpc_id = aws_vpc.k8s-vpc.id

  tags = {
    Name = "k8s_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "same_sg_rule" {
  security_group_id            = aws_security_group.k8s_sg.id
  referenced_security_group_id = aws_security_group.k8s_sg.id
  ip_protocol                  = -1
}

resource "aws_vpc_security_group_ingress_rule" "my_ip_rule" {
  security_group_id = aws_security_group.k8s_sg.id
  cidr_ipv4         = "${var.my_public_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 0
  to_port           = 65535
}

resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.k8s_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}
