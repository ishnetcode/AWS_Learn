terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"  # London — pick whatever region is close to you
  profile = "devwork"
}

resource "aws_s3_bucket" "my_first_bucket" {
  bucket = "my-first-terraform-bucket-aadya-12345"
}

output "bucket_name" {
  value = aws_s3_bucket.my_first_bucket.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.my_first_bucket.arn
}