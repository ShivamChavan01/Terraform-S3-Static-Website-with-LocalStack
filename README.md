# Terraform S3 Static Website with LocalStack

This Terraform project provisions an **S3 static website** using **LocalStack**. The setup includes an S3 bucket, public access configuration, bucket policy, website configuration, and object uploads for `index.html` and `styles.css`.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) installed.
- [LocalStack](https://docs.localstack.cloud/getting-started/) running locally.
- `index.html` and `styles.css` files in the project directory.

## Terraform Resources

### 1. Variables

```hcl
variable "region" {
  description = "This is a value for the region"
  type        = string
  default     = "eu-west-1"
}
```
Defines the AWS region used in the setup.

### 2. Providers

```hcl
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
```
Specifies the required providers (**AWS** and **Random**) and their versions.

### 3. AWS Provider Configuration (LocalStack)

```hcl
provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
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
```
Configures the AWS provider to use LocalStack.

### 4. Random ID

```hcl
resource "random_id" "rand-id" {
  byte_length = 8
}
```
Generates a unique random ID to avoid naming conflicts.

### 5. S3 Bucket

```hcl
resource "aws_s3_bucket" "myweb-app-bucket" {
  bucket = "myweb-app-bucket-${random_id.rand-id.hex}"
}
```
Creates an S3 bucket with a unique name.

### 6. Public Access Block Configuration

```hcl
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.myweb-app-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
```
Disables public access restrictions for testing purposes.

### 7. Bucket Policy

```hcl
resource "aws_s3_bucket_policy" "mywebbapp" {
  bucket = aws_s3_bucket.myweb-app-bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "AllowGetObject",
      Principal = "*",
      Effect    = "Allow",
      Action    = "s3:GetObject",
      Resource  = "arn:aws:s3:::${aws_s3_bucket.myweb-app-bucket.id}/*"
    }]
  })
}
```
Grants public read access to objects in the bucket.

### 8. S3 Website Configuration

```hcl
resource "aws_s3_bucket_website_configuration" "mywebbapp" {
  bucket = aws_s3_bucket.myweb-app-bucket.id

  index_document {
    suffix = "index.html"
  }
}
```
Configures the bucket as a **static website** with `index.html` as the default page.

### 9. Upload Website Files

```hcl
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.myweb-app-bucket.id
  source       = "./index.html"
  key          = "index.html"
  content_type = "text/html"
}
```
Uploads `index.html` to the S3 bucket.

```hcl
resource "aws_s3_object" "style_css" {
  bucket       = aws_s3_bucket.myweb-app-bucket.id
  source       = "./style.css"
  key          = "style.css"
  content_type = "text/css"
}
```
Uploads `styles.css` to the S3 bucket.

### 10. Outputs

```hcl
output "name" {
  value = random_id.rand-id.hex
}
```
Outputs the random ID used in the bucket name.

```hcl
output "my" {
  value = aws_s3_bucket_website_configuration.mywebbapp.website_endpoint
}
```
Outputs the **website URL** after deployment.

## Running the Project

### 1. Start LocalStack
```sh
localstack start
```

### 2. Initialize Terraform
```sh
terraform init
```

### 3. Apply Configuration
```sh
terraform apply -auto-approve
```

### 4. Get the Website URL
```sh
echo "Website URL: $(terraform output my)"
```

## LocalStack URL
- **S3 API URL:** `http://localhost:4566`
- **Website URL:** Run `terraform output my` to retrieve the S3 website endpoint.

## Cleanup
```sh
terraform destroy -auto-approve
```

## Notes
- **Do not use these credentials in production**; they are placeholders for LocalStack.
- The website will be served via the S3 website endpoint after deployment.
- Ensure `index.html` and `styles.css` exist in your project directory.

## Author
- **Shivam Chavan** 🚀

