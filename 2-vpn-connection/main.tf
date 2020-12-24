provider "google" {
  version = "~> 3.19.0"
  project = var.gcp_project_id
  region = var.gcp_region
}

provider "aws" {
  version = "~> 2.60.0"
  region = var.aws_region
}

