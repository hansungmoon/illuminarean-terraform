resource "aws_s3_bucket" "my_bucket" {
  bucket = "illuminarean-state-bucket" 
  acl    = "private" 

  tags = {
    Name = "My Terraform State Bucket"
    Environment = "Production"
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-state-lock" 
  billing_mode   = "PAY_PER_REQUEST"      
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "Production"
  }
}