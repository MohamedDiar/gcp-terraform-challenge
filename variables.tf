#------ root/variables.tf ------#

#---------- GCP Project Variables ------------

variable "project_name" {
  description = "The name of the GCP project to create"
  type        = string
  default     = "astrafy-project"
}

variable "project_id" {
  description = "The ID of the GCP project to create"
  type        = string
  default = "astrafy-challenge-0001"
}

variable "billing_account" {
  description = "The billing account ID to associate with the project"
  type        = string
  default     = null
}

variable "organization_id" {
  description = "The organization ID"
  type        = string
  default     = null
}

# Possible values are: "PREVENT", "ABANDON", "DELETE"
# I set the default to DELETE because I want to delete the project after destroying the resources.
# The project will be deleted upon resource destruction due to the "DELETE" deletion policy. 
# So, change to PREVENT if necessary you want to keep the project after destroying the resources.
variable "deletion_policy" {

  description = "The deletion policy for the GCP project"
  type        = string
  default     = "DELETE"
}


#---------- BIG QUERY VARIABLES ------------

variable "dataset_staging_id" {
  description = "ID for the staging dataset"
  type        = string
  default     = "staging_dataset_bitcoin"
}

variable "dataset_mart_id" {
  description = "ID for the data mart dataset"
  type        = string
  default     = "mart_dataset_bitcoin_cash"
}

variable "dataset_location" {
  description = "Location for the BigQuery datasets"
  type        = string
  default     = "US"
}

variable "service_account_id" {
  description = "ID for the BigQuery service account"
  type        = string
  default     = "bigquery-service-account"
}

variable "download_service_account_key" {
  description = "Whether to download the service account key"
  type        = bool
  default     = false
}

variable "service_account_key_path" {
  description = "Path to save the service account key"
  type        = string
  default     = "~/.dbt/service-account-key.json"
}