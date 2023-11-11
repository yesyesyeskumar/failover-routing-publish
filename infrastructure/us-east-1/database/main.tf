module "dynamodb_table_business" {
  source   = "terraform-aws-modules/dynamodb-table/aws"
  version = "3.3.0"

  billing_mode   = "PAY_PER_REQUEST"

  name     = "usertable"
  hash_key = "userId"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  replica_regions = [{
    region_name            = "us-west-2"
    propagate_tags         = true
    point_in_time_recovery = true
  }]
  

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


