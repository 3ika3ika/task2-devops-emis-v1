# Terraform-EC2-S3-IAM-CloudWatch

> *This terraform code creates infrastructure in AWS, consisting of EC2, S3, IAM, CloudWatch. The code is organised in modules to promote code reusability. Modules are called in root/main.tf.*
> 

# How to use (step by step):

### 1. Install AWS CLI (if not installed)

Check if you have aws installed on your machine:

```

aws --version
```

For **Ubuntu/Debian**:

```
sudo apt update
sudo apt install awscli -y
```

For **Amazon Linux / RHEL / CentOS**:

```
sudo yum update
sudo yum install aws-cli -y
```

For **MacOS**:

```bash
brew install awscli
```

Verify installation:

```

aws --version
```

### 2. Configure your AWS IAM User

Note: Make sure the user has programmatic access and the following permissions listed below.

You can further tighten the permissions not to have FullAccess to the services for security reasons.

```bash
AmazonEC2FullAccess
AmazonS3FullAccess
AmazonSNSFullAccess
IAMFullAccess
```

**Then configure your credentials:**

Note: The default region that you specify when running the command below will be the region of deployment

```bash
aws configure
```

### 3. Initialise Terraform modules

Note: Terraform commands are executed in root directory in the project.

```bash
terraform init
```

### 4. Validate then plan terraform infrastructure

```bash
terraform validate
```

```bash
terraform plan
```

### 5. Deploy the infrastructure to AWS

Note: You will be prompted interactively for *a* few *variables* that are user-specific. To automate this step, create a file ***terraform.tfvars*** in the root directory of the project. Then, pass desired values (make sure they exist and are within default region you specified earlier): 

```bash
*example:terraform.tfvars*

vpc_id    = "vpc-xxxxxxxxxxxxxxxxx"  # Replace with your VPC ID
subnet_id = "subnet-xxxxxxxxxxxxxxxxx"  # Replace with the desired public subnet ID
ami_id    = "ami-xxxxxxxxxxxxxxxxx"  # Replace with your desired AMI ID
endpoint_email = "my-example-email@gmail.com" #Add your email to recieve CloudWatch notifications 
bucket_name = "my-globally-unique-bucket-name" #Set globally unique bucket name
#Optional variable otherwise takes the default [0.0.0.0/0] 
#ssh_cidr = ["100.56.116.157/32"] #Replace with the IP you want to SSH from ONLY
```

**Now run:**

```bash
terraform apply -auto-approve
```

### 6. SSH into the EC2 instance

Upon terraform apply execution, the code generates a private SSH key (marked as sensitive). To make EC2 SSH possible, export the key as a file with the following command:

```bash
terraform output ec2_private_key > <your-desired-key-name>.pem
```

If you apply and destroy the infrastructure multiple times and use the same key name, use chmod 600 (re-write the content instead of setting new name to the key each time).

```bash
chmod 600 <your-desired-key-name>.pem
```

Get the public IP of the instance:

```bash
terraform output ec2_public_ip
```

SSH into the instance (ec2-user is default for Linux AMIs. For other AMIs make sure to use the correct username):

```bash
ssh -i <your-desired-key-name>.pem ec2-user@<pubic-ip-output>
```

# Resources

## EC2

- Create security group (ingress 22,80,443), ec2 instance (free tier), keypair
- Execute user scripts upon initial boot [once] (described at the bottom of the document)

## S3

- Create a private bucket with lifecycle configuration to delete objects older than 30 days, versioning enabled, object ownership ACLs enabled with Bucker owner preferred
- Upload a file **./s3_buckets/files_to_upload/space-out.png** to the bucket and make it publicly accessible

## IAM roles

- Create an IAM role with two policies: AmazonS3ReadOnlyAccess and CloudWatchLogsFullAccess
- Create IAM Instance Profile (container for IAM Role) which IAM role is attached to
- Attach to the EC2 instance

## CloudWatch

- Create CloudWatch Alarm that triggers an email notification (SNS subscription) if CPU usage exceeds 70% for 5 minutes (CloudWatch Alarm)
- Create log file with retention of 7 days **/aws/apache/logs**

## User scripts (EC2)

Upon initial boot, couple of .sh scripts are executed (in sequence defined in ./ec2_instance/user_data.sh). The scripts below are located in ./ec2_instance/user_data/

### 1. user_data_users.sh

- Install HTTPD (Apache)
- Create a new user devopsadmin with password admin, add it to the sudo group, and  restrict executing sudo su
- Disable direct root login
- Install and set firewall rules to allow only port 22, 80, 443

### 2. user_data_logs.sh

- List all running processes and find any process listening on port 8080 and log this info to **/var/log/my-script.log**
- Set up custom log rotation for **/var/log/custom_app.log**

### 3. user_data_apache.sh

- Set up Apache server as reverse proxy that forward traffic to localhost:5000
- Run Python HTTP server  in the background (port 5000) which serve the content of /var/www/html/index.html
- Now when you try to reach the Public IPv4 DNS (make sure to use http NOT https) of the EC2 instance, you are redirected to the python server on port 5000
- *TIP: Uncomment location block and replace IP to allow only specific CIDR to access the server*

```
<Location />
       #Require ip 192.168.1.0/24 #Uncomment and replace with proper CIDR to make restrictions active 
    </Location>
```

### 4. user_data_cron.sh

- Install Apache if not present
- Start and enable Apache
- Start Python HTTP server
- Install Cron if not installed
- Create script  and cron job to check Apache and Python every 5 minutes **CHECK_SCRIPT="/home/ec2-user/check_httpd.sh”**
- logs of cron job **LOG_FILE="/var/log/apache_check.log”**

### user_data_cloudwatch_agent.sh

- Create CloudWatch Agent conf file to trail Apache logs **/var/log/httpd/access_log**
- Add the file to log group and log stream (which is within the log group)

# Useful commands within EC2 instance

## CloudWatch

### Test CPU alarm (may take longer than 5 min (insufficient data → alarm)

```bash
sudo yum install -y stress
```

```bash
stress --cpu 1 --timeout 600
```

Monitor with:

```bash
top
```

### Test CloudWatch Agent for Apache logs (user_data_cloudwatch_agent.sh)

If the agent is working:

```bash
sudo systemctl status amazon-cloudwatch-agent
```

Check the logs for any abnormalities:

```bash
sudo cat /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
```

List if log group was created:

```bash
aws logs describe-log-groups

```

List log streams:

```bash
aws logs describe-log-streams --log-group-name "/aws/apache/logs"

```

List Apache logs (each time you try to access the Public IPv4 DNS a record is created**)**

```bash
sudo cat /var/log/httpd/access_log
```

## CRON (user_data_cron.sh)

List cron jobs 

```bash
sudo crontab -l
```

Check cron job executions log 

```bash
sudo cat /var/log/apache_check.log
```

Check Python web server logs. That file has log rotation setup in user_data_logs.sh 

```bash
sudo cat /var/log/custom_app.log
```

## USERS & FireWall

List all human users

```bash
awk -F: '$3 >= 1000 {print $1}' /etc/passwd
```

Check currently logged under 

```bash
whoami
```

Log in to another user

```bash
su - <username>
```

Check sudo priviledges of current user

```bash
sudo -l
```

Check the current firewall rules:

```bash
sudo firewall-cmd --list-all
```