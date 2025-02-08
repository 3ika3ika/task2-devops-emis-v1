#!/bin/bash

# Log file path
LOG_FILE="/var/log/apache_check.log"

# Log function
log_message() {
  echo "$(date) - $1" >> $LOG_FILE
}

log_message "Starting Apache check..."

# Install Apache if not present
if ! command -v httpd >/dev/null; then
  log_message "Apache not found. Installing..."
  sudo yum update -y >> $LOG_FILE 2>&1
  sudo yum install -y httpd >> $LOG_FILE 2>&1
  log_message "Apache installed."
else
  log_message "Apache is already installed."
fi

# Start Apache if it's not running
if ! pgrep -x "httpd" > /dev/null; then
  log_message "Apache not running. Starting..."
  sudo systemctl start httpd >> $LOG_FILE 2>&1
  sudo systemctl enable httpd >> $LOG_FILE 2>&1
  log_message "Apache started and enabled on boot."
else
  log_message "Apache is already running."
fi

# Start Python HTTP server if not running
if ! pgrep -f "python3 -m http.server 5000" > /dev/null; then
  log_message "Python server not running. Starting..."
  sudo nohup python3 -m http.server 5000 > /var/log/custom_app.log 2>&1 &
else
  log_message "Python server is running."
fi

# Install Cron and set up monitoring
sudo yum install -y cronie
sudo systemctl start crond 
sudo systemctl enable crond 
log_message "Setting up cron job for checks every 5 minutes..."
(crontab -l 2>/dev/null; echo "*/5 * * * * /bin/bash /home/ec2-user/check_httpd.sh") | sudo crontab - >> $LOG_FILE 2>&1

# Create script to check services
log_message "Creating check_httpd.sh..."
cat <<EOL | sudo tee /home/ec2-user/check_httpd.sh > /dev/null
#!/bin/bash

LOG_FILE="/var/log/apache_check.log"

# Check Apache
if ! pgrep -x "httpd" > /dev/null; then
  echo "\$(date) - Apache not running. Restarting..." >> \$LOG_FILE
  sudo systemctl restart httpd >> \$LOG_FILE 2>&1
else
  echo "\$(date) - Apache is running." >> \$LOG_FILE
fi

# Check Python server
if ! pgrep -f "python3 -m http.server 5000" > /dev/null; then
  echo "\$(date) - Python server not running. Starting..." >> \$LOG_FILE
  SERVER_DIR="/var/www/html"
  sudo nohup bash -c "cd $SERVER_DIR && python3 -m http.server 5000" > /var/log/custom_app.log 2>&1 &
else
  echo "\$(date) - Python server is running." >> \$LOG_FILE
fi
EOL

# Make the check script executable
log_message "Making check_httpd.sh executable..."
sudo chmod +x /home/ec2-user/check_httpd.sh >> $LOG_FILE 2>&1

log_message "Apache check script complete."
