#!/bin/bash -v
sudo yum update -y
sudo yum install nginx -y > /tmp/nginx.log

sudo yum install amazon-cloudwatch-agent -y

