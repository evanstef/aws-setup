data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_launch_template" "app" {
    name_prefix = "app-${var.environment}-"
    image_id = data.aws_ami.ubuntu.id
    instance_type = "t3.micro"
}

# ini untuk autoscalling server nya 
resource "aws_autoscaling_group" "app" {
    name = "app-${var.environment}-asg"
    min_size = 2
    max_size = 6
    desired_capacity = 2
    target_group_arns = [aws_lb_target_group.app.arn]
    vpc_zone_identifier = var.private_subnet_ids   # server ASG gunakan private subnet
    launch_template {
        id = aws_launch_template.app.id
        version = "$Latest"
    }
}

resource "aws_autoscaling_policy" "app_policy" {
   name = "cpu-target-policy-${var.environment}"
   autoscaling_group_name = aws_autoscaling_group.app.name
   policy_type = "TargetTrackingScaling"

   target_tracking_configuration {
      predefined_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"
      } 
      target_value = 50.0
   }
}

# setup aws load balancer
resource "aws_lb" "app" {
    name               = "app-${var.environment}-alb"
    load_balancer_type = "application"
    subnets            = var.public_subnet_ids   # alb gunakan public subnet
  }
  
resource "aws_lb_target_group" "app" {
    name     = "app-${var.environment}-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = var.target_group_vpc_id

    health_check {
        path = "/"
    }
}

# bikin lb listener buat yang http dan juga https juga 
resource "aws_acm_certificate" "app" {
    domain_name = var.domain_name
    validation_method = "DNS"
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.app.arn
    port = 80
    protocol = "HTTP"
    default_action {
        type = "redirect"
        redirect {
            port = "443"
            protocol = "HTTPS"
            status_code = "HTTP_301"
        }
    }
}

resource "aws_lb_listener" "https" {
    load_balancer_arn = aws_lb.app.arn
    port              = 443
    protocol          = "HTTPS"
    ssl_policy        = "ELBSecurityPolicy-2016-08"
    certificate_arn   = aws_acm_certificate.app.arn
    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.app.arn
    } 
}
