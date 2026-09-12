resource "aws_lb_target_group" "k8s-nodes-tg" {
  name               = "k8s-nodes-tg"
  port               = 6443
  protocol           = "TCP"
  vpc_id             = aws_vpc.k8s-vpc.id
  ip_address_type    = "ipv4"
  preserve_client_ip = false

  health_check {
    path     = "/readyz"
    port     = 6443
    protocol = "HTTPS"
  }
}

resource "aws_lb_target_group_attachment" "k8s-nodes-tg-attach" {
  count = length(aws_instance.control_plane_instance)

  target_group_arn = aws_lb_target_group.k8s-nodes-tg.arn
  target_id        = aws_instance.control_plane_instance[count.index].id
}

# Create the cluster internal load balancer 
resource "aws_lb" "private_cluster_nlb" {
  # if single control plane then load balancer is not needed
  # count = var.node_count == 1 ? 0 : 1

  load_balancer_type               = "network"
  security_groups                  = [aws_security_group.k8s_internal_lb_sg.id]
  subnets                          = aws_subnet.k8s-subnets[*].id
  enable_cross_zone_load_balancing = true
  internal                         = true
}

resource "aws_lb_listener" "private_lb_listener" {
  load_balancer_arn = aws_lb.private_cluster_nlb.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s-nodes-tg.arn
  }
}



resource "aws_lb_target_group" "k8s-nodes-tg-public" {
  name               = "k8s-nodes-tg-public"
  port               = 6443
  protocol           = "TCP"
  vpc_id             = aws_vpc.k8s-vpc.id
  ip_address_type    = "ipv4"

  health_check {
    path     = "/readyz"
    port     = 6443
    protocol = "HTTPS"
  }
}

resource "aws_lb_target_group_attachment" "k8s-nodes-tg-public-attach" {
  count = length(aws_instance.control_plane_instance)

  target_group_arn = aws_lb_target_group.k8s-nodes-tg-public.arn
  target_id        = aws_instance.control_plane_instance[count.index].id
}
# Create the public facing load balancer
resource "aws_lb" "public_cluster_nlb" {
  # if single control plane then load balancer is not needed
  # count = var.node_count == 1 ? 0 : 1

  load_balancer_type               = "network"
  security_groups                  = [aws_security_group.k8s_public_lb_sg.id]
  subnets                          = aws_subnet.k8s-subnets[*].id
  enable_cross_zone_load_balancing = true
  internal                         = false
}

resource "aws_lb_listener" "public_lb_listener" {
  load_balancer_arn = aws_lb.public_cluster_nlb.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s-nodes-tg-public.arn
  }
}