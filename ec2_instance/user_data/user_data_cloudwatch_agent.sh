#!/bin/bash

# Install CloudWatch Agent
sudo yum install -y amazon-cloudwatch-agent

# Create CloudWatch Agent configuration file for Apache logs
sudo touch /var/log/httpd/access_log
sudo chmod 644 /var/log/httpd/access_log
sudo chown apache:apache /var/log/httpd/access_log

cat <<EOL > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/httpd/access_log",
            "log_group_name": "/aws/apache/logs",
            "log_stream_name": "test-stream-dshahudfisfghuidusuifgisgfih"
          }
        ]
      }
    }
  }
}
EOL

# Start the CloudWatch Agent using systemctl
sudo systemctl start amazon-cloudwatch-agent

# Enable the CloudWatch Agent to start on boot (if not already enabled)
sudo systemctl enable amazon-cloudwatch-agent

# Verify CloudWatch Agent status
sudo systemctl status amazon-cloudwatch-agent

# Optionally restart the CloudWatch Agent (in case of any config changes)
#sudo systemctl restart amazon-cloudwatch-agent
