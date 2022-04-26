# lambda function running a docker image
# this function hits our service on a time interval to see if it is still healty

locals {
  account_id          = data.aws_caller_identity.current.account_id
  ecr_repository_url  = "873715421885.dkr.ecr.us-west-1.amazonaws.com/healthcheck"
  ecr_repository_name = "healthcheck"
  ecr_image_tag       = "latest"
}

data "aws_ecr_image" "lambda_image" {
  repository_name = local.ecr_repository_name
  image_tag       = local.ecr_image_tag
}

resource "aws_iam_role" "lambda" {
  name               = "${var.environment}-lambda-role"
  assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Action": "sts:AssumeRole",
           "Principal": {
               "Service": "lambda.amazonaws.com"
           },
           "Effect": "Allow"
       }
   ]
}
 EOF
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect    = "Allow"
    resources = ["*"]
    sid       = "CreateCloudWatchLogs"
  }
}

resource "aws_iam_policy" "lambda" {
  name   = "${var.environment}-lambda-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_lambda_function" "healthcheck" {
  function_name = "${var.environment}-lambda"
  role          = aws_iam_role.lambda.arn
  timeout       = 300
  image_uri     = "${local.ecr_repository_url}@${data.aws_ecr_image.lambda_image.id}"
  package_type  = "Image"
}