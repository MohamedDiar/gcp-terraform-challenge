#------ modules/gcp-terraform-challenge/main.tf ---------


# This creates a Google Cloud Project with the specified parameters.
resource "google_project" "project" {
  name            = var.project_name_in
  project_id      = var.project_id_in
  org_id          = var.organization_id_in
  billing_account = var.billing_account_in
  deletion_policy = var.deletion_policy_in
}

