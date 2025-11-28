output "load_balancer_dns" {
  value = aws_lb.alb.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.mysql1.endpoint
}

output "asg_name" {
  value = aws_autoscaling_group.auto_lbs.name
}
