data "aws_ami" "amzon_linux" {
  owners = ["amazon"]
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
resource "aws_launch_configuration" "web" {
  image_id = data.aws_ami.amzon_linux.id
  instance_type = "t3.micro"
  security_groups = [aws_security_group.web_server.id]
  user_data = <<EOF
    #!/bin/bash
yum -y update
yum -y install httpd
PRIVATE_IP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo “Web Server has $PRIVATE_IP “ > /var/www/html/index.html
systemctl start httpd
systemctl enable httpd
    EOF
}



resource "aws_autoscaling_group" "web" {
    name_prefix = "Web"
    desired_capacity = 2
    max_size = 4
    min_size = 2
    vpc_zone_identifier = aws_subnet.public[*].id 
    health_check_type = "EC2"
    default_cooldown = 300
    launch_configuration = aws_launch_configuration.web.name
    target_group_arns = [aws_lb_target_group.web.arn]
  
}

resource "aws_lb" "web" {
    internal = false
    security_groups = [aws_security_group.web_server.id]
    subnets = aws_subnet.public.*.id 
    enable_deletion_protection = false

  
}

resource "aws_lb_target_group" "web" {
    name = "web"
    port = 80
    protocol = "HTTP"
    vpc_id =  aws_vpc.main_vpc.id   
}

resource "aws_lb_listener" "web_end" {
    load_balancer_arn = aws_lb.web.arn
    port = "80"
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.web.arn
    }
}

resource "aws_autoscaling_attachment" "web" {
    autoscaling_group_name = aws_autoscaling_group.web.id
    alb_target_group_arn = aws_lb_target_group.web.arn
}

resource "aws_autoscaling_policy" "cpu-up" {
  name                   = "cpu-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 125
  autoscaling_group_name = aws_autoscaling_group.web.name
}

resource "aws_cloudwatch_metric_alarm" "cpu-check" {
  alarm_name          = "cpu-alarm-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "51"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.cpu-up.arn]
}

resource "aws_autoscaling_policy" "cpu-down" {
  name                   = "cpu-up"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 125
  autoscaling_group_name = aws_autoscaling_group.web.name
}

resource "aws_cloudwatch_metric_alarm" "cpu-check-down" {
  alarm_name          = "cpu-alarm-down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "45"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.cpu-down.arn]
}