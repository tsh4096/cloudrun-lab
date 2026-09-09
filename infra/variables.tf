variable "project_id" {
  description = "ID des Google-Cloud-Projekts"
  type        = string
  # Kein default: eine falsche Projekt-ID soll frueh knallen,
  # nicht still ins falsche Projekt deployen.
}

variable "region" {
  description = "Region fuer Cloud Run und Artifact Registry"
  type        = string
  default     = "europe-west3"
}

variable "service_name" {
  description = "Name des Cloud-Run-Dienstes"
  type        = string
  default     = "hello-lab"
}

variable "container_image" {
  description = "Vollstaendiger Pfad des Container-Images"
  type        = string
  # Beim ersten Lauf zeigt das auf Googles oeffentliches Hello-Image,
  # damit die Infrastruktur steht, bevor du selbst ein Image baust.
  default = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "repository_id" {
  description = "Name des Artifact-Registry-Repositories"
  type        = string
  default     = "apps"
}

variable "min_instances" {
  description = "Mindestanzahl laufender Instanzen. 0 heisst: kostet nichts, wenn niemand zugreift, dafuer Kaltstart."
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Obergrenze der Instanzen. Schuetzt vor Kostenexplosion bei Lastspitzen oder Fehlern."
  type        = number
  default     = 2
}

variable "allow_public_access" {
  description = "Darf jeder den Dienst aufrufen. Fuer die Uebung ja, produktiv fast nie."
  type        = bool
  default     = true
}

variable "github_owner" {
  description = "Dein GitHub-Benutzer oder deine Organisation"
  type        = string
}

variable "github_repo" {
  description = "Name des Repositories, ohne Owner"
  type        = string
}

variable "wif_pool_id" {
  description = "ID des Workload-Identity-Pools"
  type        = string
  default     = "github-pool"
}

variable "wif_provider_id" {
  description = "ID des Providers innerhalb des Pools"
  type        = string
  default     = "github-provider"
}

variable "deployer_sa_id" {
  description = "Konto-ID des Service Accounts, mit dem die Pipeline arbeitet"
  type        = string
  default     = "gha-deployer"
}