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
