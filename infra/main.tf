# Die Image-Ablage. Terraform legt sie an, danach schiebst du
# eigene Images hinein.
resource "google_artifact_registry_repository" "apps" {
  location      = var.region
  repository_id = var.repository_id
  format        = "DOCKER"
  description   = "Images fuer das Cloud-Run-Lab"
}

# Der eigentliche Dienst.
resource "google_cloud_run_v2_service" "app" {
  name     = var.service_name
  location = var.region

  # Zweite Stolperstelle: neuere Provider-Versionen setzen dieses Feld
  # standardmaessig auf true. Dann verweigert terraform destroy den Dienst
  # und du raetselst, warum das Aufraeumen scheitert. Fuer ein Lab
  # ausdruecklich auf false, produktiv laesst man es auf true.
  deletion_protection = false

  # Wer den Dienst im Netz erreichen darf. INGRESS_TRAFFIC_ALL heisst:
  # aus dem offenen Internet. Das ist die Netzwerkebene, die Frage
  # nach der Authentifizierung wird weiter unten separat geregelt.
  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    containers {
      image = var.container_image

      # Cloud Run gibt dem Container die Portnummer ueber die
      # Umgebungsvariable PORT vor. Der Container MUSS auf genau
      # diesem Port lauschen, sonst gilt der Start als gescheitert.
      ports {
        container_port = 8080
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }
  }
}

# Rechte auf dem Dienst. "allUsers" mit der Rolle run.invoker bedeutet:
# jeder darf aufrufen, auch ohne Anmeldung. Das ist bewusst getrennt
# von ingress: ingress regelt, wer ueberhaupt anklopfen darf,
# diese Bindung regelt, wer eingelassen wird.
resource "google_cloud_run_v2_service_iam_member" "public" {
  count = var.allow_public_access ? 1 : 0

  location = google_cloud_run_v2_service.app.location
  name     = google_cloud_run_v2_service.app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}