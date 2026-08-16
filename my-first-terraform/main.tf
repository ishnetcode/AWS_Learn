resource "aws_s3_bucket" "my_first_bucket" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "my_first_bucket_versioning" {
  bucket = aws_s3_bucket.my_first_bucket.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "my_first_bucket_lifecycle" {
  bucket = aws_s3_bucket.my_first_bucket.id

  rule {
    id     = "expire-old-objects"
    status = "Enabled"

    filter {}

    expiration {
      days = var.lifecycle_expiration_days
    }
  }
}

provider "aws" {
  region  = "eu-west-2"
  profile = "devwork"
}

output "bucket_name" {
  value = aws_s3_bucket.my_first_bucket.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.my_first_bucket.arn
}