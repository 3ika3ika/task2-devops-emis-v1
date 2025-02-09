resource "aws_s3_bucket" "task2_bucket" {
  bucket = var.bucket_name  # Change this to a unique bucket name
}

resource "aws_s3_bucket_ownership_controls" "task2_ownership" {
  bucket = aws_s3_bucket.task2_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_public_access_block" "task2_block" {
  bucket = aws_s3_bucket.task2_bucket.id

  block_public_acls          = false  # Allow public ACLs on objects
  ignore_public_acls         = false  # Don't ignore public ACLs
  block_public_policy        = false  # Allow public bucket policies
  
}
resource "aws_s3_bucket_acl" "task2_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.task2_ownership]

  bucket = aws_s3_bucket.task2_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "task2_versioning" {
    bucket = aws_s3_bucket.task2_bucket.id
    versioning_configuration {
      status = "Enabled"
    }
  }

resource "aws_s3_bucket_lifecycle_configuration" "task2_lifecycle" {
  bucket = aws_s3_bucket.task2_bucket.id

  rule {
    id     = "delete-old-objects"
    status = "Enabled"

    filter {
      prefix = ""  # Apply to all objects in the bucket
    }

    expiration {
      days = 30  # Delete objects older than 30 days
    }
  }
}

resource "aws_s3_object" "my_file" {
  bucket = aws_s3_bucket.task2_bucket.id
  key    = var.file_name
  source = "./s3_buckets/files_for_upload/space-out.png"  # The local path to your JPG image
  acl    = "public-read"  # Make the image publicly accessible
}

output "image_url" {
  value = "https://${aws_s3_bucket.task2_bucket.bucket}.s3.amazonaws.com/${aws_s3_object.my_file.key}"
}