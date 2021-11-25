# AWS Route 53 Variables
variable "route53_mydomain" {
  description = "Domain Name"
  type = string 
  default = "domain.com"
}

variable "route53_apps_default_dns" {
  description = "Default DNS Name"
  type = string 
  default = "myapps.domain.com"
}

variable "route53_host_header_dns1" {
  description = "Host Header DNS Name"
  type = string 
  default = "host-header.domain.com"
}
