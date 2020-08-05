provider "aws" {
  region     = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_iam_role" "linux_role" {
  name = "linux_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    Name = "${var.customer_prefix}-${var.environment}-linux-iam-role"
  }
}

resource "aws_iam_instance_profile" "linux_profile" {
  name = "linux_profile"
  role = aws_iam_role.linux_role.name
}

resource "aws_iam_role_policy" "linux_policy" {
  name = "linux_policy"
  role = aws_iam_role.linux_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [ "*" ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}