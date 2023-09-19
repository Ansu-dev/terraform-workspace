terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.17.0" # 최신 버전
    }
  }

  backend "s3" { # backend를 s3를 사용할꺼라는 명시
    bucket = "tf-backend-ansu"
    key = "terraform.tfstate"
    region = "ap-northeast-2"
  }
}

provider "aws" {
  region = "ap-northeast-2"
}


module "main_vpc" {
  source = "./custom_vpc"
  env = terraform.workspace # terraform 객체는 root module에서만 사용
}

# 권한 설정도 필요함
resource "aws_s3_bucket" "tf_backend" {
  count = terraform.workspace == "default" ? 1 : 0 # 개발일 경우에만 생성되는 버킷
  bucket = "tf-backend-ansu"

  tags = {
    Name = "tf-backend"
  }
}


resource "aws_s3_bucket_versioning" "tf_backend_versioning" {
  count = terraform.workspace == "default" ? 1 : 0 # 개발일 경우에만 생성되는 버킷
  bucket = aws_s3_bucket.tf_backend[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# 23.04월 부터 바뀐 정책으로 ownership_control을 추가해 acl을 추가 할 수 있다.
resource "aws_s3_bucket_ownership_controls" "tf_backend_ownership_controls" {
  count = terraform.workspace == "default" ? 1 : 0 # 개발일 경우에만 생성되는 버킷
  bucket = aws_s3_bucket.tf_backend[0].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "tf_backend_acl" {
  count = terraform.workspace == "default" ? 1 : 0 # 개발일 경우에만 생성되는 버킷

  # ownership에 대한 의존성 주입
  depends_on = [aws_s3_bucket_ownership_controls.tf_backend_ownership_controls]

  bucket = aws_s3_bucket.tf_backend[0].id
  acl = "private"
}