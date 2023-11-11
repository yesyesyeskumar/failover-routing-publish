module "dynamodb_table_business" {
  source   = "terraform-aws-modules/dynamodb-table/aws"
  version = "3.3.0"

  billing_mode   = "PROVISIONED"
  read_capacity  = 2
  write_capacity = 2

  name     = "usertable"
  hash_key = "userId"
  

  attributes = [
    {
      name = "userId"
      type = "S"
    }
  ]

  tags = {
    Terraform   = "true"
  }
}