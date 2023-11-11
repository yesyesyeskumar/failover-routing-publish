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
    name               = "custlambdarole-west"
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
    name               = "custasgrole-west"
    assume_role_policy = data.aws_iam_policy_document.asginstance-assume-role-policy.json
    inline_policy {
        name   = "policy-867530231"
        policy = data.aws_iam_policy_document.cust_asginstance_access.json
    }

}

resource "aws_iam_instance_profile" "custasgprofile" {
  name = "custasgprofile-west"
  role = "${aws_iam_role.custasgrole.name}"
}