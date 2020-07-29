provider "aws" {
  region     = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}
/*
resource "aws_route_table_association" "rta" {
  for_each = toset(var.subnet_ids)
  subnet_id = each.value
  route_table_id = var.route_table_id
}
*/

resource "aws_route_table_association" "rta" {
  subnet_id      = var.subnet_ids
  route_table_id = var.route_table_id
}
