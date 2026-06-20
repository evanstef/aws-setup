terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = "ap-southeast-1"
}

# Bucket tempat nyimpen state SEMUA proyek terraform lain
resource "aws_s3_bucket" "tfstate" {
    bucket = "evnxc-tfstate-825475390189"
}

# Versioning — tiap perubahan state ke-backup, bisa rollback kalau korup
resource "aws_s3_bucket_versioning" "tfstate" {
    bucket = aws_s3_bucket.tfstate.id
    versioning_configuration {
        status = "Enabled"
    }
}

# Enkripsi default — state isinya rahasia (password plaintext)
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
    bucket = aws_s3_bucket.tfstate.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

# Tutup total akses publik
resource "aws_s3_bucket_public_access_block" "tfstate" {
    bucket                  = aws_s3_bucket.tfstate.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}
