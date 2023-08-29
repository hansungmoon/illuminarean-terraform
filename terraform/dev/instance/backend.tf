terraform {
  backend "s3" {
    bucket = "illuminarean-state-bucket"
    key    = "dev/instance/terraform.tfstate"
    region = "ap-northeast-2"

    dynamodb_table = "terraform-state-lock"
    encrypt        = true  
  }
}