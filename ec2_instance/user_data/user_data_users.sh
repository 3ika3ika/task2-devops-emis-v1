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
