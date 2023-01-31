## create S3 bucket 
resource "aws_s3_bucket" "abkhan-prod-bucket" {
  bucket = "abkhan-prod-bucket"

  tags = {
   Environment = "Production"
  }
}

resource "aws_s3_bucket_acl" "myacl" {
  bucket = aws_s3_bucket.abkhan-prod-bucket.id
  acl    = "private"
 
}

resource "aws_s3_bucket_versioning" "abkhan-versioning" {
  bucket = aws_s3_bucket.abkhan-prod-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_public_access_block" "abkhan-blockpubaccess" {
  bucket = aws_s3_bucket.abkhan-prod-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# create key and server side encryption
resource "aws_kms_key" "abkhan-s3key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 15
}

resource "aws_s3_bucket_server_side_encryption_configuration" "abkhan-SSE" {
  bucket = aws_s3_bucket.abkhan-prod-bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.abkhan-s3key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "public_read_access" {
bucket  = aws_s3_bucket.abkhan-prod-bucket.id
policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "ExamplePolicy",
    "Statement": [
        {
            "Sid": "AllowSSLRequestsOnly",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::abkhan-prod-bucket",
                "arn:aws:s3:::abkhan-prod-bucket/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
EOF
}
 


resource "aws_s3_object" "abkhan-prod-bucket" {
 bucket        = var.bucket
  key           = var.key
  
  force_destroy = var.force_destroy
  acl           = var.acl
  storage_class = var.storage_class
  server_side_encryption = var.server_side_encryption
  kms_key_id             = var.kms_key_id
  tags = var.tags

  lifecycle {
    ignore_changes = [object_lock_retain_until_date]
  }
}
