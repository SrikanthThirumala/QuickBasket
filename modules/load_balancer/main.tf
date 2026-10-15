
resource "aws_lb" "sri_quickbasket_alb" {
  name               = "sri-quickbasket-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [var.sri_public_subnets_ids[0], var.sri_public_subnets_ids[1]]
  security_groups    = [var.sri_quickbasket_Frontend_ALB_SG_id]
}

# Frontend Target Group (Port 3000)
resource "aws_lb_target_group" "sri_quickbasket_frontend_tg" {
  name     = "sri-quickbasket-frontend-tg"
  vpc_id   = var.sri_vpc_id
  port     = 3000
  protocol = "HTTP"

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group_attachment" "sri_quickbasket_frontend_tg_attach" {
  target_group_arn = aws_lb_target_group.sri_quickbasket_frontend_tg.arn
  target_id        = var.sri_quickbasket_front_end_server_id
  port             = 3000
}

# Backend Target Group (Port 5000)
resource "aws_lb_target_group" "sri_quickbasket_backend_tg" {
  name     = "sri-quickbasket-backend-tg"
  vpc_id   = var.sri_vpc_id
  port     = 5000
  protocol = "HTTP"

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group_attachment" "sri_quickbasket_backend_tg_attach" {
  target_group_arn = aws_lb_target_group.sri_quickbasket_backend_tg.arn
  target_id        = var.sri_quickbasket_back_end_server_id
  port             = 5000
}

# Listener: Default forward to Frontend 
resource "aws_lb_listener" "sri_quickbasket_http_listener" {
  load_balancer_arn = aws_lb.sri_quickbasket_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sri_quickbasket_frontend_tg.arn
  }
}

# Listener Rule: Route /api/* directly to Backend 
resource "aws_lb_listener_rule" "api_routing" {
  listener_arn = aws_lb_listener.sri_quickbasket_http_listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sri_quickbasket_backend_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}