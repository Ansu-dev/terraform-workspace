output "vpc_id" { # 외부에서 하위모듈의 값이 필요할 경우
  value = aws_vpc.default.id
}