# Create IAM role
resource "aws_iam_role" "s3_cloudawatch" {
  name = "EC2S3ReadOnlyANDCloudWatchFullAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach S3 read-only policy
resource "aws_iam_policy_attachment" "s3_readonly_attach" {
  name       = "s3_readonly_attachment"
  roles      = [aws_iam_role.s3_cloudawatch.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Attach CloudWatch Logs policy to the EC2 role
resource "aws_iam_policy_attachment" "cloudwatch_logs_attach" {
  name       = "cloudwatch_logs_attachment"
  roles      = [aws_iam_role.s3_cloudawatch.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}


#Create IAM Instance Profile (container for IAM Role) which is then assigned to EC2 isntance 
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "S3CloudWatchProfileEC2"
  role = aws_iam_role.s3_cloudawatch.name
}

