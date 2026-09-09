output "service_url" {
  description = "Adresse, unter der der Dienst erreichbar ist"
  value       = google_cloud_run_v2_service.app.uri
}

# Diese beiden Werte traegst du gleich als GitHub-Variablen ein.
output "workload_identity_provider" {
  description = "Vollstaendiger Name des WIF-Providers fuer die Pipeline"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "deployer_service_account" {
  description = "E-Mail des Service Accounts fuer die Pipeline"
  value       = google_service_account.deployer.email
}

output "image_repo_path" {
  description = "Basispfad, unter den eigene Images gepusht werden"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.apps.repository_id}"
}