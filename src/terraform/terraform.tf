terraform {
  required_version = ">=1.10.3"

  cloud {
    organization = "PaolaSiako"
    workspaces {
      name = "cloud-project"
    }
  }
}

