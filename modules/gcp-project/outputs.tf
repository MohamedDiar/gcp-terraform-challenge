#------ modules/modules/gcp-project/outputs.tf ------#

output "project_id_out" {
  value = google_project.project.project_id
}