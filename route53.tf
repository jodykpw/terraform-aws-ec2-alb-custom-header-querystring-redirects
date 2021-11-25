# AWS Route 53

# Get DNS information from AWS Route53
data "aws_route53_zone" "mydomain" {
  name         = var.route53_mydomain
}

# DNS Registration 
resource "aws_route53_record" "default_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id 
  name    = var.route53_apps_default_dns
  type    = "A"
  alias {
    name                   = module.alb.this_lb_dns_name
    zone_id                = module.alb.this_lb_zone_id
    evaluate_target_health = true
  }  
}

## Testing Host Header - Redirect to External Site from ALB HTTPS Listener Rules
resource "aws_route53_record" "host_headers_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id 
  name    = var.route53_host_header_dns1
  type    = "A"
  alias {
    name                   = module.alb.this_lb_dns_name
    zone_id                = module.alb.this_lb_zone_id
    evaluate_target_health = true
  }  
}

