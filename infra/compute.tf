resource "yandex_compute_instance" "kittygram_vm" {
  name        = "kittygram-vm"
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.vm_image_id
      size     = 15
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.kittygram_subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.kittygram_sg.id]
  }

  metadata = {
    ssh-keys  = "ubuntu:${file(var.ssh_pub_key_path)}"
  }

  connection {
    type        = "ssh"
    host        = self.network_interface[0].nat_ip_address
    user        = "ubuntu"
    private_key = file("~/.ssh/id_ed25519")
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      # Обновляем пакеты и устанавливаем необходимые утилиты
      "sudo apt-get update -o Acquire::ForceIPv4=true",
      "sudo apt-get install -y -o Acquire::ForceIPv4=true apt-transport-https ca-certificates curl gnupg lsb-release",

      # Добавляем официальный репозиторий Docker
      "curl -4 -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",

      # Обновляем apt после добавления репозитория
      "sudo apt-get update -o Acquire::ForceIPv4=true",

      # Устанавливаем Docker и дополнительные компоненты
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin",

      # Запускаем и включаем Docker
      "sudo systemctl enable docker",
      "sudo systemctl start docker",

      # Добавляем пользователя ubuntu в группу docker
      "sudo usermod -aG docker ubuntu",

      # Проверяем установку Docker
      "docker --version"
    ]
  }
}
