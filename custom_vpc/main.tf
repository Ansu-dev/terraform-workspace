resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "fastcampus_default_vpc_${var.env}" #env라는 변수를 참조한다.
  }
}

resource "aws_subnet" "public_subnet_1" {
  count = var.env == "prod" ? 0 : 1 # 개발과 운영의 생성 예외처리
  vpc_id = aws_vpc.default.id
  cidr_block = "10.0.0.0/24"
  availability_zone = local.az_a # 가용영역 A

  tags = {
    Name = "fastcampus_public_subnet_1_${var.env}"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.default.id
  cidr_block = "10.0.100.0/24"
  availability_zone = local.az_a # 가용영역 A

  tags = {
    Name = "fastcampus_private_subnet_1_${var.env}"
  }
}
