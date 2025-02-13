variable "region" {
  description = "This is a value for the region"
  type        = string
  default     = "eu-west-1"

}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" 
      version = "5.54.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}

provider "aws" {
  access_key                  = "LKIAQAAAAAAAIOFPSI36" 
  secret_key                  = "p4VoUAkjIKZKyTAQco/KtX5fRIZjDye/DuxJvo+C"
  region                      = var.region
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  endpoints {
    s3  = "http://localhost:4566"
    ec2 = "http://localhost:4566" 
  }
}

resource "random_id" "rand-id" {
  byte_length = 8

}

resource "aws_s3_bucket" "myweb-app-bucket" {
  bucket = "myweb-app-bucket-${random_id.rand-id.hex}"

}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.myweb-app-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_policy" "mywebbapp" {
  bucket = aws_s3_bucket.myweb-app-bucket.id
  policy = jsonencode(

    {
      Version = "2012-10-17",
      Statement = [
        {
        Sid       = "AllowGetObject",
        Principal = "*"
        Effect    = "Allow",
        Action    = "s3:GetObject",
        Resource  = "arn:aws:s3::: ${aws_s3_bucket.myweb-app-bucket.id}/*"
       }
     ]
    }
  )

}

resource "aws_s3_bucket_website_configuration" "mywebbapp" {
  bucket = aws_s3_bucket.myweb-app-bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.myweb-app-bucket.id
  source = "./index.html"
  key    = "index.html"
  content_type = "text/html"


}


resource "aws_s3_object" "style_css" {
  bucket = aws_s3_bucket.myweb-app-bucket.id
  source = "./style.css"
  key    = "style.css"
  content_type = "text/css "

}


output "name" {
  value = random_id.rand-id.hex
}

output "my" {
    value = aws_s3_bucket_website_configuration.mywebbapp.website_endpoint
  
}