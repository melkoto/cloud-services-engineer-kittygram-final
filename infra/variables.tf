variable "yc_token" {
  description = "API токен для доступа к Yandex Cloud"
  type        = string
  default     = "y0__xD4katQGMHdEyCz5anXEp-MPDju5eenWNbQfumjC3QB9HOn"
}

variable "yc_cloud_id" {
  description = "ID облака в Yandex Cloud"
  type        = string
  default     = "b1g445s7divgt6d0aber"
}

variable "yc_folder_id" {
  description = "ID каталога (folder) в Yandex Cloud"
  type        = string
  default     = "b1gdfpndo7v8cf2ngmo7"
}

variable "yc_zone" {
  description = "Зона доступности (например, ru-central1-a)"
  type        = string
  default     = "ru-central1-b"
}

variable "subnet_cidr" {
  description = "CIDR блок для подсети"
  type        = list(string)
  default     = ["192.168.10.0/24"]
}

variable "vm_image_id" {
  description = "ID образа для загрузочного диска ВМ"
  type        = string
  # yc compute image list --folder-id standard-images | grep -i ubuntu
  default     = "fd80bm0rh4rkepi5ksdi" # ubuntu-24-04-lts-v20250324
}

variable "ssh_pub_key_path" {
  description = "Путь к публичному SSH-ключу"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}
