#!/bin/bash

set -euxo pipefail

echo "Starting html,css and javascript website deployment...."

sudo yum update -y
sudo yum upgrade -y

sudo yum install -y git httpd

cd ${website_directory}

sudo git clone ${github_repository} temp

sudo mv temp/* .
sudo rm -r temp

sudo chown -R apache:apache ${website_directory}
sudo chown -R 755 ${website_directory}

sudo systemctl enable httpd
sudo systemctl start httpd   