# Создание облачной сети (VPC)
resource "yandex_vpc_network" "kittygram_network" {
  name = "kittygram-network"
}

# Создание подсети внутри сети
resource "yandex_vpc_subnet" "kittygram_subnet" {
  name           = "kittygram-subnet"
  network_id     = yandex_vpc_network.kittygram_network.id
  zone           = var.yc_zone
  v4_cidr_blocks = var.subnet_cidr
}

# Security Group для Kittygram: разрешаем входящие соединения только на SSH и HTTP
resource "yandex_vpc_security_group" "kittygram_sg" {
  name        = "kittygram-sg"
  description = "Security Group для Kittygram: разрешаем входящие соединения только на SSH (22) и HTTP (80)"
  network_id  = yandex_vpc_network.kittygram_network.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
