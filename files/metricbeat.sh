#!/bin/bash -xe
cd /tmp/
sudo yum update -y
curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.10.1-x86_64.rpm
sudo rpm -vi metricbeat-7.10.1-x86_64.rpm
sudo metricbeat modules disable system
sudo rm /etc/metricbeat/metricbeat.yml
sudo mv /tmp/metricbeat.yml /etc/metricbeat/metricbeat.yml
sudo chown root:root /etc/metricbeat/metricbeat.yml
sudo metricbeat modules enable aws
sudo metricbeat setup
sudo service metricbeat start
sudo systemctl enable metricbeat


curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.10.1-x86_64.rpm
sudo rpm -vi filebeat-7.10.1-x86_64.rpm
sudo rm /etc/filebeat/filebeat.yml
sudo mv /tmp/filebeat.yml /etc/filebeat/filebeat.yml
sudo chown root:root /etc/filebeat/filebeat.yml
sudo filebeat modules enable aws
sudo rm /etc/filebeat/modules.d/aws.yml
sudo mv /tmp/aws.yml /etc/filebeat/modules.d/aws.yml
sudo chown root:root /etc/filebeat/modules.d/aws.yml


sudo filebeat setup || true
sudo service filebeat start
sudo systemctl enable filebeat