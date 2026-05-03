#!/bin/bash

set -euxo pipefail

echo "Starting html,css and javascript website deployment...."

sudo yum update -y
sudo yum upgrade -y

sudo yum install -y git httpd

cd ${website_directory}

sudo tee index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>HubSpot Project</title>
</head>
<body>
    <h1>Welcome to My Website</h1>
    <p>File created via terminal using sudo, tee, and EOF.</p>
</body>
</html>
EOF

sudo chown -R apache:apache ${website_directory}
sudo chmod -R 755 ${website_directory}

sudo systemctl enable httpd
sudo systemctl start httpd   