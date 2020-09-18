data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "parameter-store-document" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "ssm:GetParameter", "ssm:GetParameterByPath"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "parameter_store_policy" {
  policy = data.aws_iam_policy_document.parameter-store-document.json
}

resource "aws_iam_role" "parameter_store_role" {
  name               = "parameter_store_role"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}

resource "aws_iam_policy_attachment" "parameter-store-attach" {
  name       = "parameter-store-attach"
  roles      = [aws_iam_role.parameter_store_role.name]
  policy_arn = aws_iam_policy.parameter_store_policy.arn
}

resource "aws_iam_instance_profile" "parameter_store_profile" {
  name = "parameter_sotre_profile"
  role = aws_iam_role.parameter_store_role.name
}
