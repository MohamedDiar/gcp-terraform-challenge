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

# Possible values are: "PREVENT", "ABANDON", "DELETE"
# I set the default to DELETE because I want to delete the project after destroying the resources.
# The project will be deleted upon resource destruction due to the "DELETE" deletion policy. 
# So, change to PREVENT if necessary you want to keep the project after destroying the resources.
variable "deletion_policy" {

  description = "The deletion policy for the GCP project"
  type        = string
  default     = "DELETE"
}