# Diese Datei legt fest, WOMIT gebaut wird: Terraform-Version,
# Provider-Version und wo der State liegt.

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    google = {
      source = "hashicorp/google"
      # Aktuelle Major-Version ist 8.x (geprueft am 09.09.2026).
      # "~> 8.0" heisst: alles ab 8.0, aber kein Sprung auf 9.0.
      # Ein Major-Sprung bringt fast immer Aenderungen an Feldnamen mit,
      # deshalb wird er nie automatisch mitgenommen.
      version = "~> 8.0"
    }
  }

  # Der Backend-Block sagt, wo der State liegt.
  # Achtung, das ist die erste echte Stolperstelle: hier sind KEINE
  # Variablen erlaubt. Terraform liest diesen Block, bevor Variablen
  # ueberhaupt existieren. Die Werte kommen deshalb beim init von aussen,
  # ueber eine Backend-Konfigurationsdatei. Deswegen steht hier nur
  # der leere Block.
  backend "gcs" {}
}

# Der Provider ist der Uebersetzer zwischen Terraform und der Google-API.
provider "google" {
  project = var.project_id
  region  = var.region
}