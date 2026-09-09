# Der Pool ist die Klammer um alle externen Identitaeten,
# denen du in diesem Projekt vertraust.
resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = var.wif_pool_id
  display_name              = "GitHub Actions"
  description               = "Externe Identitaeten aus GitHub Actions"
}

# Der Provider beschreibt EINE konkrete Vertrauensquelle,
# hier GitHubs Token-Aussteller.
resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = var.wif_provider_id
  display_name                       = "GitHub OIDC"

  # DER wichtigste Punkt der ganzen Datei.
  # GitHub benutzt EINEN Aussteller fuer alle Nutzer weltweit.
  # Ohne diese Bedingung koennte jedes beliebige GitHub-Repository
  # der Welt ein gueltiges Token vorzeigen und in dein Projekt hinein.
  # Google verlangt die Bedingung deshalb zwingend, ein Provider
  # ohne sie wird mit INVALID_ARGUMENT abgelehnt.
  attribute_condition = "assertion.repository_owner == '${var.github_owner}'"

  # Uebersetzung der Felder aus GitHubs Token in Google-Attribute.
  # google.subject ist Pflicht, der Rest macht die Attribute
  # spaeter in Bedingungen und Bindungen benutzbar.
  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }

  oidc {
    # Feste Adresse von GitHubs Token-Aussteller.
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Das Konto, unter dem die Pipeline in Google arbeitet.
resource "google_service_account" "deployer" {
  account_id   = var.deployer_sa_id
  display_name = "GitHub Actions Deployer"
}

# Die Bruecke: dieses eine Repository darf sich als dieser
# Service Account ausgeben. principalSet ist eine Menge externer
# Identitaeten, hier eingegrenzt auf genau ein Repository.
resource "google_service_account_iam_member" "github_can_impersonate" {
  service_account_id = google_service_account.deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_owner}/${var.github_repo}"
}

# Was der Deployer im Projekt darf. Bewusst einzeln aufgezaehlt
# statt roles/editor. Jede Rolle hier ist eine bewusste Entscheidung,
# und genau danach wird in einem Review gefragt.
locals {
  deployer_roles = [
    "roles/run.admin",               # Cloud-Run-Dienste anlegen und aendern
    "roles/artifactregistry.writer", # Images hochladen
    "roles/iam.serviceAccountUser",  # den Laufzeit-Account an Cloud Run weiterreichen
    "roles/storage.objectAdmin",     # State-Datei im Bucket lesen und schreiben
  ]
}

resource "google_project_iam_member" "deployer_roles" {
  for_each = toset(local.deployer_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.deployer.email}"
}