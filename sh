#!/bin/bash

# Update system and install HTTPD
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

# Create a new user and modify SSH and sudoers
sudo useradd -m -s /bin/bash devopsadmin
echo "devopsadmin:admin" | sudo chpasswd
sudo usermod -aG wheel devopsadmin
echo "devopsadmin    ALL=(ALL)    !/usr/bin/su" | sudo tee -a /etc/sudoers.d/devopsadmin > /dev/null
sudo sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Install firewalld and set rules
sudo yum install -y firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --permanent --add-port=22/tcp
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload

# Process & Logs Management
echo "Listing all running processes:" | sudo tee -a /var/log/my-script.log
sudo ps aux >> /var/log/my-script.log
echo "Checking for processes listening on port 8080:" | sudo tee -a /var/log/my-script.log
sudo lsof -i :8080 >> /var/log/my-script.log

# Set up custom log file and rotation
sudo touch /var/log/custom_app.log
sudo chmod 644 /var/log/custom_app.log
sudo cat <<EOL | sudo tee /etc/logrotate.d/custom_app > /dev/null
/var/log/custom_app.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 0644 root root
    sharedscripts
    postrotate
        systemctl reload custom_app.service > /dev/null 2>&1 || true
    endscript
}
EOL

echo "Log rotation for /var/log/custom_app.log has been set up."

# Configure Apache as a reverse proxy
sudo cat <<EOL | sudo tee /etc/httpd/conf.d/reverse-proxy.conf > /dev/null
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html

    ProxyPreserveHost On
    ProxyPass / http://localhost:5000/
    ProxyPassReverse / http://localhost:5000/

    <Location />
        Require ip 192.168.1.0/24
    </Location>

    <Directory "/var/www/html">
        Require all granted
    </Directory>
</VirtualHost>
EOL

# Restart Apache to apply changes
sudo systemctl restart httpd

# Set the homepage HTML
echo "<h1>${env_var}</h1>" | sudo tee /var/www/html/index.html > /dev/null

# Start a Python HTTP server on port 5000 in the background
sudo nohup python3 -m http.server 5000  > /var/log/custom_app.log 2>&1 &



# Define log file path
LOG_FILE="/var/log/apache_check.log"

# Function to log messages
log_message() {
  echo "$(date) - $1" >> $LOG_FILE
}

# Start logging
log_message "Starting Apache check script..."

# Install httpd (Apache) if not already installed
if ! command -v httpd >/dev/null 2>&1; then
  log_message "httpd (Apache) is not installed. Installing httpd..."
  sudo yum update -y >> $LOG_FILE 2>&1
  sudo yum install -y httpd >> $LOG_FILE 2>&1
  log_message "httpd installation complete."
else
  log_message "httpd is already installed."
fi

# Check if httpd is running
if ! pgrep -x "httpd" > /dev/null; then
  log_message "httpd is not running. Starting httpd..."
  sudo systemctl start httpd >> $LOG_FILE 2>&1
  sudo systemctl enable httpd >> $LOG_FILE 2>&1
  log_message "httpd started and enabled to run on boot."
else
  log_message "httpd is already running."
fi

# Create a cron job to check httpd every 5 minutes
log_message "Adding cron job to check httpd every 5 minutes..."
(crontab -l 2>/dev/null; echo "*/5 * * * * /bin/bash /home/ec2-user/check_httpd.sh") | sudo crontab - >> $LOG_FILE 2>&1

# Create the check_httpd.sh script to check httpd status every 5 minutes
log_message "Creating check_httpd.sh script..."
cat <<EOL | sudo tee /home/ec2-user/check_httpd.sh > /dev/null
#!/bin/bash

# Log the check
LOG_FILE="/var/log/apache_check.log"
echo "\$(date) - Checking if httpd is running..." >> \$LOG_FILE

# Check if httpd is running
if ! pgrep -x "httpd" > /dev/null; then
  echo "\$(date) - httpd is not running. Restarting httpd..." >> \$LOG_FILE
  sudo systemctl restart httpd >> \$LOG_FILE 2>&1
else
  echo "\$(date) - httpd is running." >> \$LOG_FILE
fi
EOL

# Make check_httpd.sh executable
log_message "Making check_httpd.sh executable..."
sudo chmod +x /home/ec2-user/check_httpd.sh >> $LOG_FILE 2>&1

log_message "Apache check script complete."
