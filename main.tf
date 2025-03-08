#------ root/main.tf ------#

# Module for GCP project
module "gcp_project" {
  source = "./modules/gcp-project"

  project_name_in    = var.project_name
  project_id_in      = var.project_id
  billing_account_in = var.billing_account
  organization_id_in = var.organization_id
  deletion_policy_in = var.deletion_policy
}

# Module for GCP BigQuery
module "gcp_bigquery" {
  source = "./modules/gcp-bigquery"
}
