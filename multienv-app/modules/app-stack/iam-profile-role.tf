# buat ngambil account id
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "app_server" {
  name = "devops-app-server-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "read_db_secret" {
  name = "devops-app-server-policy-${var.environment}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "ssm:GetParameter"
      Resource = "arn:aws:ssm:ap-southeast-1:${data.aws_caller_identity.current.account_id}:parameter/app/db-password"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "app_server_policy_attachment" {
  role       = aws_iam_role.app_server.name
  policy_arn = aws_iam_policy.read_db_secret.arn
}

resource "aws_iam_instance_profile" "app_server" {
  name = "devops-app-instance-profile-${var.environment}"
  role = aws_iam_role.app_server.name
}
