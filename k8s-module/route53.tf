resource "aws_route53_zone" "cluster_private_zone" {
  name = var.hosted_zone_name

  vpc {
    vpc_id = aws_vpc.k8s-vpc.id
  }
}

resource "aws_route53_record" "control_plane_domain_name" {
  count = local.cp_node_count

  zone_id = aws_route53_zone.cluster_private_zone.id
  name    = "${var.control_plane_node_name_prefix}${count.index}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.control_plane_instance[count.index].private_ip]
}

resource "aws_route53_record" "cluster_internal_endpoint_record" {
  zone_id = aws_route53_zone.cluster_private_zone.id
  name    = var.nlb_record_name
  type    = "A"

  alias {
    name                   = aws_lb.private_cluster_nlb.dns_name
    zone_id                = aws_lb.private_cluster_nlb.zone_id
    evaluate_target_health = false
  }
}
