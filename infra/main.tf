terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.89.0"
    }
  }

  backend "s3" {
    endpoint                   = "https://storage.yandexcloud.net"
    bucket                     = "kitty-backet"
    region                     = "ru-central1"
    key                        = "tf-state/terraform.tfstate"
    skip_region_validation     = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}
