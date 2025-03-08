#------ modules/gcp-bigquery/main.tf ---------


# Enabling BigQuery API in cases it is not already enabled
resource "google_project_service" "bigquery" {
  project = var.project_id_in
  service = "bigquery.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy        = true
}


# Creation of service account
resource "google_service_account" "bigquery_service_account" {
  account_id   = var.service_account_id_in
  display_name = "BigQuery Service Account"
  project      = var.project_id_in
}

# To Create service account key
resource "google_service_account_key" "bigquery_key" {

  service_account_id = google_service_account.bigquery_service_account.name
}

# To only download the key of the service account if needed/requested
resource "local_file" "bigquery_key_file" {
  count    = var.download_service_account_key_in ? 1 : 0
  content  = base64decode(google_service_account_key.bigquery_key.private_key)
  filename = pathexpand(var.service_account_key_path_in)

  lifecycle {
    ignore_changes = all
  }
}

# Creation of staging dataset
resource "google_bigquery_dataset" "staging_dataset" {
  dataset_id    = var.dataset_staging_id_in
  friendly_name = "Staging Dataset"
  description   = "Dataset for staging tables"
  location      = var.dataset_location_in
  project       = var.project_id_in
  default_table_expiration_ms = 3456000000  # 40 days
  default_partition_expiration_ms = 3456000000  
  depends_on    = [google_project_service.bigquery] 
}

# Creation of Data mart dataset
resource "google_bigquery_dataset" "mart_dataset" {
  dataset_id    = var.dataset_mart_id_in
  friendly_name = "Data Mart Dataset"
  description   = "Dataset for data mart tables"
  location      = var.dataset_location_in
  project       = var.project_id_in
  default_table_expiration_ms = 3456000000
  default_partition_expiration_ms = 3456000000
  depends_on    = [google_project_service.bigquery]
}

#-----Permissions to service account------

# This resource grants the BigQuery Job User role at the project level.
# By assigning "roles/bigquery.jobUser" to the service account, it allows that account to execute BigQuery jobs like running queries or load operations.
# within the specified project. The role is assigned to the service account referenced by its email.
resource "google_project_iam_member" "bigquery_job_user" {
  project = var.project_id_in
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.bigquery_service_account.email}"
}

# This resource grants the BigQuery Data Editor role on the staging dataset.
# The "roles/bigquery.dataEditor" role allows the service account to perform tasks such as creating, inserting into, updating, or deleting tables in the staging dataset.
resource "google_bigquery_dataset_iam_member" "staging_editor" {
  dataset_id = google_bigquery_dataset.staging_dataset.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.bigquery_service_account.email}"
  project    = var.project_id_in
}
# This resource grants the BigQuery Data Editor role on the mart dataset
resource "google_bigquery_dataset_iam_member" "mart_editor" {
  dataset_id = google_bigquery_dataset.mart_dataset.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.bigquery_service_account.email}"
  project    = var.project_id_in
}
