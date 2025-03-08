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

  project_id_in                   = module.gcp_project.project_id_out
  dataset_staging_id_in           = var.dataset_staging_id
  dataset_mart_id_in              = var.dataset_mart_id
  dataset_location_in             = var.dataset_location
  service_account_id_in           = var.service_account_id
  download_service_account_key_in = var.download_service_account_key
  service_account_key_path_in     = var.service_account_key_path
}
