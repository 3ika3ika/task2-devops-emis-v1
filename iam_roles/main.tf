# Create IAM role
resource "aws_iam_role" "ec2_s3_readonly" {
  name = "EC2S3ReadOnlyRole"

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
  roles      = [aws_iam_role.ec2_s3_readonly.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

#Create IAM Instance Profile (container for IAM Role) which is then assigned to EC2 isntance 
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2S3ReadOnlyProfile"
  role = aws_iam_role.ec2_s3_readonly.name
}