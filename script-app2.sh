#! /bin/bash
# Instance Identity Metadata Reference - https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-identity-documents.html
sudo yum update -y
sudo yum install -y httpd
sudo systemctl enable httpd
sudo service httpd start  
sudo echo '<h1>Terraform Demo - App 2</h1>' | sudo tee /var/www/html/index.html
sudo mkdir /var/www/html/app2
sudo echo '<h1>Terraform Demo - App 2 Sub-folder</h1>' | sudo tee /var/www/html/app2/index.html
sudo curl http://169.254.169.254/latest/dynamic/instance-identity/document -o /var/www/html/app2/metadata.html