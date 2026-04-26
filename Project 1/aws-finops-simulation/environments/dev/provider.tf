provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "aws-finops-simulation"
      Owner       = "swapnil"
      CostCenter  = "finops-labs"
      ManagedBy   = "terraform"
    }
  }
}