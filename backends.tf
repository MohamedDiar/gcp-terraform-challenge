terraform {
  cloud {

    organization = "mo-terraform"

    workspaces {
      name = "gcp-infra"
    }
  }
}

#  Option to deploy to manage state locally to specific folder
# terraform {
#   backend "local" {
#     path = "state/terraform.tfstate"
#   }
# }