terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.11.0"
      configuration_aliases = [ aws.dr ]
    }
  }

}

provider "aws" {
  alias = "dr"
  region = "us-west-2"
}




data "aws_iam_policy_document" "custlambda-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cust_lambda_access" {
  statement {
    actions   = ["logs:*","s3:*","dynamodb:*","cloudwatch:*","sns:*","lambda:*","secretsmanager:*","ds:*","ec2:*"]
    effect   = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role" "custlambdarole" {
    name               = "custlambdarole"
    assume_role_policy = data.aws_iam_policy_document.custlambda-assume-role-policy.json
    inline_policy {
        name   = "policy-867530231"
        policy = data.aws_iam_policy_document.cust_lambda_access.json
    }

}



data "aws_iam_policy_document" "asginstance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cust_asginstance_access" {
  statement {
    actions   = ["logs:*","s3:*","dynamodb:*","cloudwatch:*","sns:*","lambda:*","connect:*","secretsmanager:*","ds:*","ec2:*"]
    effect   = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role" "custasgrole" {
    name               = "custasgrole"
    assume_role_policy = data.aws_iam_policy_document.asginstance-assume-role-policy.json
    inline_policy {
        name   = "policy-867530231"
        policy = data.aws_iam_policy_document.cust_asginstance_access.json
    }

}

resource "aws_iam_instance_profile" "custasgprofile" {
  name = "custasgprofile"
  role = "${aws_iam_role.custasgrole.name}"
}




# role for s3 replication

# data for an existing s3 bucket
data "aws_s3_bucket" "app_s3_bucket" {
  provider = aws.dr
    bucket = var.destination_bucket_name
}

data "aws_iam_policy_document" "s3_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "s3_replication" {
  name               = "s3-replication"
  assume_role_policy = data.aws_iam_policy_document.s3_assume_role.json
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [var.source_bucket_arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${var.source_bucket_arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${data.aws_s3_bucket.app_s3_bucket.arn}/*"]
  }
}

resource "aws_iam_policy" "replication" {
  name   = "tf-iam-role-policy-replication-12345"
  policy = data.aws_iam_policy_document.replication.json
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.s3_replication.name
  policy_arn = aws_iam_policy.replication.arn
}