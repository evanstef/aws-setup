terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        } 
    }
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_budgets_budget" "monthly" {
  name = "monthly-cost-budget"
  budget_type = "COST"
  limit_amount = "5"
  limit_unit = "USD"
  time_unit = "MONTHLY"
  
  notification {
    comparison_operator = "GREATER_THAN"
    threshold = 80
    threshold_type = "PERCENTAGE"
    notification_type = "FORECASTED"
    subscriber_email_addresses = [var.account]
  }
}
