# Configure Apache as a reverse proxy
sudo cat <<EOL | sudo tee /etc/httpd/conf.d/reverse-proxy.conf > /dev/null
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html

    ProxyPreserveHost On
    ProxyPass / http://localhost:5000/
    ProxyPassReverse / http://localhost:5000/

    <Location />
       #Require ip 192.168.1.0/24 #Uncomment and replace with proper CIDR to make restrictions active 
    </Location>

    <Directory "/var/www/html">
        Require all granted
    </Directory>
</VirtualHost>
EOL

# Restart Apache to apply changes
sudo systemctl restart httpd

# Set the homepage HTML
echo "<h1>$ENV_VAR</h1>" | sudo tee /var/www/html/index.html > /dev/null

# Start a Python HTTP server on port 5000 in the background
SERVER_DIR="/var/www/html"
sudo nohup bash -c "cd $SERVER_DIR && python3 -m http.server 5000" > /var/log/custom_app.log 2>&1 &
