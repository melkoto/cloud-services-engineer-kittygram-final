output "kittygram_vm_nat_ip" {
  value       = yandex_compute_instance.kittygram_vm.network_interface.0.nat_ip_address
  description = "Публичный IP адрес виртуальной машины для Kittygram"
}
