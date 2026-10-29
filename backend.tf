terraform {
  backend "s3" {
    bucket       = "sasikala-tf-state-48213"
    key          = "terraform-aws-project/terraform.tfstate"
    region       = "ap-southeast-2"
    encrypt      = true
    use_lockfile = true
  }
}