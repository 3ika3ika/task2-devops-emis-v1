#!/bin/bash

# Log file path
LOG_FILE="/var/log/apache_check.log"

# Log function
log_message() {
  echo "$(date) - $1" >> $LOG_FILE
}

log_message "Starting initial setup..."

# Install Apache if not present
if ! command -v httpd >/dev/null; then
  log_message "Apache not found. Installing..."
  sudo yum update -y >> $LOG_FILE 2>&1
  sudo yum install -y httpd >> $LOG_FILE 2>&1
  log_message "Apache installed."
fi

# Start and enable Apache
sudo systemctl start httpd >> $LOG_FILE 2>&1
sudo systemctl enable httpd >> $LOG_FILE 2>&1
log_message "Apache started and enabled on boot."

# Start Python HTTP server to serve from /var/www/html
SERVER_DIR="/var/www/html"
log_message "Starting Python HTTP server from $SERVER_DIR..."
sudo nohup bash -c "cd $SERVER_DIR && python3 -m http.server 5000" > /var/log/custom_app.log 2>&1 &

# Install Cron if not installed
if ! command -v crontab >/dev/null; then
  sudo yum install -y cronie
  sudo systemctl start crond
  sudo systemctl enable crond
  log_message "Cron installed and started."
fi

# Create script to check services
CHECK_SCRIPT="/home/ec2-user/check_httpd.sh"
log_message "Creating $CHECK_SCRIPT..."
cat <<EOL | sudo tee $CHECK_SCRIPT > /dev/null
#!/bin/bash
LOG_FILE="/var/log/apache_check.log"
SERVER_DIR="/var/www/html"

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
  sudo nohup bash -c "cd \$SERVER_DIR && python3 -m http.server 5000" > /var/log/custom_app.log 2>&1 &
else
  echo "\$(date) - Python server is running." >> \$LOG_FILE
fi
EOL

# Make check script executable
sudo chmod +x $CHECK_SCRIPT
log_message "Check script created and made executable."

# Add cron job for monitoring (avoid duplicates)
log_message "Setting up cron job for checks every 5 minutes..."
(crontab -l 2>/dev/null | grep -v "$CHECK_SCRIPT"; echo "*/5 * * * * /bin/bash $CHECK_SCRIPT") | sudo crontab -

log_message "Setup complete."