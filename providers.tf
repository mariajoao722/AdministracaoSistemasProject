terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.60"
    }
  }
}

provider "google" {
  project     = "projectadms"
  region      = "europe-southwest1"
  credentials = "./projectadms-key.json"
}