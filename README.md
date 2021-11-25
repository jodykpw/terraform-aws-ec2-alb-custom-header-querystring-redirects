# AWS EC2 Application Load Balancer (Custom Header and Query Parameter Based Routing) using Terraform

![image](https://drive.google.com/uc?export=view&id=1hiZryuhsNHeN_IITmUfQ46f7JT2MbuHc)

## Pre-requisite

- You need a Registered Domain in AWS Route53 to implement this usecase
- Create `private-key` folder
- Copy your AWS EC2 Key pair `terraform-key.pem` in `private-key` folder

## Populating Variables

The values for these variables should be placed into terraform.tfvars. Simply copy terraform.tfvars.example to terraform.tfvars and edit it with the proper values.

## Execute Terraform Commands

terraform init

terraform validate

terraform plan

terraform apply

## Verify via AWS Management Console

Observation:

1. Verify EC2 Instances created
2. Verify VPC
3. Verify Subnets
4. Verify IGW
5. Verify Public Route for Public Subnets
6. Verify no public route for private subnets
7. Verify NAT Gateway and Elastic IP for NAT Gateway
8. Verify NAT Gateway route for Private Subnets
9. Verify no public route or no NAT Gateway route to Database Subnets
10. Verify Subnets Security Group
11. Verify Load Balancer Security Group (80 and SSL 443 Rule)
12. Verify ALB Listener - HTTP:80 - Should contain a redirect from HTTP to HTTPS
13. Verify ALB Listener - HTTPS:443

```t
13.1 Rule-1: custom-header=app1 should go to App1 EC2 Instances

13.2 Rule-2: custom-header=app2 should go to App2 EC2 Instances

13.3 Rule-3: When Query-String, terraform-aws-modules=alb redirect to https://github.com//terraform-aws-modules/terraform-aws-alb/tree/v5.16.0

13.4 Rule-4: When Host Header = http://${var.rule4_conditions_host_headers}, redirect to https://${var.rule4_action_hosts}/${var.rule4_action_path}
```

14. Verify ALB Target Groups App1 and App2, Targets (should be healthy)
15. Verify SSL Certificate (Certificate Manager)
16. Verify Route53 DNS Record
17. Verify Tags

## Connect to Bastion EC2 Instance and Test

```t
# Connect to Bastion EC2 Instance from local desktop
ssh -i private-key/terraform-key.pem ec2-user@<PUBLIC_IP_FOR_BASTION_HOST>

# Curl Test for Bastion EC2 Instance to Private EC2 Instances
curl  http://<Private-Instance-App1-Private-IP>
curl  http://<Private-Instance-App2-Private-IP>

# Connect to Private EC2 Instances App 1 from Bastion EC2 Instance
ssh -i /tmp/terraform-key.pem ec2-user@<Private-Instance-App1-Private-IP>
cd /var/www/html
ls -lrta
Observation: 
1) Should find index.html
2) Should find app1 folder
3) Should find app1/index.html file
4) Should find app1/metadata.html file

# Connect to Private EC2 Instances App 2 from Bastion EC2 Instance
ssh -i /tmp/terraform-key.pem ec2-user@<Private-Instance-App2-Private-IP>
cd /var/www/html
ls -lrta
Observation: 
1) Should find index.html
2) Should find app2 folder
3) Should find app2/index.html file
4) Should find app2/metadata.html file
```

## Verify HTTP Header Based Routing (Rule-1 and Rule-2)

- Use Postman to test Rule-1 and Rule-2

```t
https://myapps.domain.com
custom-header = app1  - Should get the page from App1 
custom-header = app2  - Should get the page from App2
```

## Verify Rule-3

```t
https://myapps.domain.com/?terraform-aws-modules=alb
Observation: 
1. Should Redirect to https://github.com/terraform-aws-modules/terraform-aws-alb/tree/v5.16.0
```

## Verify Rule-4

```t
http://${var.rule4_conditions_host_headers}
Observation: 
1. Should redirect to https://${var.rule4_action_hosts}/${var.rule4_action_path}
```

## Terraform Destroy

terraform destroy

## Clean-Up

rm -rf .terraform*

rm -rf terraform.tfstate*
