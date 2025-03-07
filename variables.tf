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