
locals {
  
  users_map = { for item in jsondecode(file("${path.module}/users.json")) : 
    item.userId => item }

}

resource "aws_dynamodb_table_item" "user_table_items" {
  for_each = local.users_map
  table_name = "usertable"
  hash_key   = "userId"

  item = <<ITEM
{
  "userId": {"S": "${each.value.userId}"},
  "username": {"S": "${each.value.username}"},
  "name": {"S": "${each.value.name}"},
  "status": {"S": "${each.value.status}"},
  "email": {"S": "${each.value.email}"}
}
ITEM
}