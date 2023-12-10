terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.60"
    }
    # postgresql= {
    #   source = "crunchydata/postgresql"
    #   version = "~> 10"
    # }
  }
}

provider "google" {
  project     = "projectadms"
  region      = "europe-southwest1"
  credentials = "./projectadms-key.json"
}

# provider "postgresql" {
#   host = "localhost"
#   username = "user"
#   password = "password"
#   port = 5432
# }