provider "aws" {
  region = "us-west-2"
  profile = "tempcloud"
}


resource "aws_lb" "sri_netf_Frontend-ALB" {
  name = "sri-netf-Frontend-ALB"
  subnets = [ aws_subnet.sri_netf_public_1.id,aws_subnet.sri_netf_public_2.id ]
  load_balancer_type = "application"
  security_groups = [ aws_security_group.sri_netf_ALB_SG.id ]
  depends_on = [ aws_instance.sri_netf_front_end_server ]

}

resource "aws_lb_target_group" "sri_netf_Frontend-TG-1" {
  depends_on = [ aws_lb.sri_netf_Frontend-ALB ]
  name = "sri-netf-Frontend-TG-1"
  vpc_id = aws_vpc.sri_netf_vpc.id
  port = "80"
  protocol = "HTTP"
  health_check {
    port = "traffic-port"
    path = "/"
  }
}

resource "aws_lb_target_group_attachment" "sri_netf_Frontend-TG-Attch-1" {
  target_group_arn = aws_lb_target_group.sri_netf_Frontend-TG-1.arn
  port = "80"
  target_id = aws_instance.sri_netf_front_end_server.id
  
}

resource "aws_lb_listener" "sri-netf-Frontend-ALB-listener" {
  load_balancer_arn = aws_lb.sri_netf_Frontend-ALB.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.sri_netf_Frontend-TG-1.arn
    type = "forward"
  }
}
