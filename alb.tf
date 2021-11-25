# AWS Application and Network Load Balancer (ALB & NLB) Terraform Module
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "5.16.0"

  name = "${local.name}-alb"
  load_balancer_type = "application"
  vpc_id = module.vpc.vpc_id
  subnets = [
    module.vpc.public_subnets[0],
    module.vpc.public_subnets[1]
  ]
  security_groups = [module.alb_sg.this_security_group_id]
  # Listeners
  # HTTP Listener - HTTP to HTTPS Redirect
    http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]  
  # Target Groups
  target_groups = [
    # App1 Target Group - TG Index = 0
    {
      name_prefix          = "app1-"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/app1/index.html"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      protocol_version = "HTTP1"
      # App1 Target Group - Targets
      targets = {
        app1_vm1 = {
          target_id = module.ec2_private_app1.id[0]
          port      = 80
        },
        app1_vm2 = {
          target_id = module.ec2_private_app1.id[1]
          port      = 80
        }
      }
      tags =local.common_tags # Target Group Tags
    },  
    # App2 Target Group - TG Index = 1
    {
      name_prefix          = "app2-"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/app2/index.html"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      protocol_version = "HTTP1"
      # App2 Target Group - Targets
      targets = {
        app2_vm1 = {
          target_id = module.ec2_private_app2.id[0]
          port      = 80
        },
        app2_vm2 = {
          target_id = module.ec2_private_app2.id[1]
          port      = 80
        }
      }
      tags =local.common_tags # Target Group Tags
    }  
  ]

  # HTTPS Listener
  https_listeners = [
    # HTTPS Listener Index = 0 for HTTPS 443
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.this_acm_certificate_arn
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Fixed static message - for Root Context"
        status_code  = "200"
      }
    }, 
  ]

  # HTTPS Listener Rules
  https_listener_rules = [
    # Rule-1: custom-header forward to ec2_private_app1
    { 
      https_listener_index = 0
      priority = 1  
      actions = [
        {
          type               = "forward"
          target_group_index = 0
        }
      ]
      conditions = [{ 
        http_headers = [{
          http_header_name = "custom-header"
          values           = ["app1"]
        }]
      }]
    },
    # Rule-2: custom-header forward to ec2_private_app2
    {
      https_listener_index = 0
      priority = 2      
      actions = [
        {
          type               = "forward"
          target_group_index = 1
        }
      ]
      conditions = [{
        http_headers = [{
          http_header_name = "custom-header"
          values           = ["app2"]
        }]        
      }]
    },
  # Rule-3: When Query-String, terraform-aws-modules=alb redirect to https://github.com/terraform-aws-modules/terraform-aws-alb/tree/v5.16.0
    { 
      https_listener_index = 0
      priority = 3
      actions = [{
        type        = "redirect"
        status_code = "HTTP_302"
        host        = "github.com"
        path        = "/terraform-aws-modules/terraform-aws-alb/tree/v5.16.0"
        query       = ""
        protocol    = "HTTPS"
      }]
      conditions = [{
        query_strings = [{
          key   = "terraform-aws-modules"
          value = "alb"
          }]
      }]
    },
  # Rule-4: When conditions host_headers redirect to specific url
    { 
      https_listener_index = 0
      priority = 4
      actions = [{
        type        = "redirect"
        status_code = "HTTP_302"
        host        = var.rule4_action_hosts
        path        = var.rule4_action_path
        query       = ""
        protocol    = var.rule4_action_protocol
      }]
      conditions = [{
        host_headers = var.rule4_conditions_host_headers
      }]
    },
  ]
  
  tags = local.common_tags # ALB Tags
}
