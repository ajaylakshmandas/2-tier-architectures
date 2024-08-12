resource "aws_dynamodb_table" "dynamodb" {
  count = 2 
  name  = count.index == 0 ? "PublicTable" : "PrivateTable"
  billing_mode = "PROVISIONED"  # Use "PAY_PER_REQUEST" for on-demand mode

  hash_key   = "id"
  range_key  = "timestamp"

  attribute {
    name = "id"
    type = "S"  # S for string, N for number, B for binary
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  # Provisioned throughput settings
  read_capacity  = 5
  write_capacity = 5

  tags = {
    Name        = count.index == 0 ? "PublicTable" : "PrivateTable"
    Environment = "Dev"
  }
}
