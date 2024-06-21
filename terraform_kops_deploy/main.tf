provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "kops_state_store" {
  bucket = "my-kops-state-store"
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_route53_zone" "main" {
  name = "example.com"
}

resource "aws_iam_role" "kops" {
  name = "kops"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "kops_AmazonEC2FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = aws_iam_role.kops.name
}

resource "aws_iam_role_policy_attachment" "kops_AmazonS3FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.kops.name
}

resource "aws_iam_role_policy_attachment" "kops_AmazonVPCFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
  role       = aws_iam_role.kops.name
}

