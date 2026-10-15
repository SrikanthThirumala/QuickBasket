
output "backend_alb_dns_name" {
  value = aws_lb.sri_quickbasket_alb.dns_name
  description = "backend_alb_dns_name name value to pass it for compute module for frontend ec2 "
}