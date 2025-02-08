#!/bin/bash

# Install awslogs
sudo yum install -y awslogs

# Install CloudWatch Agent
REGION="us-west-3"
cd /tmp
sudo wget https://d1vvhvl2y92vvt.cloudfront.net/latest/awslogs/awslogs-agent-setup.py
sudo python3 awslogs-agent-setup.py --region $REGION

# Get the EC2 instance ID
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Configure CloudWatch Agent to collect Apache logs
sudo bash -c "cat <<EOF > /etc/awslogs/config/apache.conf
[apache]
log_group_name = /aws/apache/logs
log_stream_name = ${INSTANCE_ID}
file = /var/log/httpd/access_log
datetime_format = %Y-%m-%d %H:%M:%S
EOF"

# Restart the awslogs service to apply configuration
sudo service awslogs restart
