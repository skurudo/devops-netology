output "vpc-internal-ip" {
  value = yandex_compute_instance.vpc.network_interface.0.ip_address
}

output "vpc-external-ip" {
  value = yandex_compute_instance.vpc.network_interface.0.nat_ip_address
}

output "vpc2-internal-ip" {
  value = yandex_compute_instance.vpc2.network_interface.0.ip_address
}

output "vpc2-external-ip" {
  value = yandex_compute_instance.vpc2.network_interface.0.nat_ip_address
}

output "vpc3-internal-ip" {
  value = yandex_compute_instance.vpc3.network_interface.0.ip_address
}

output "vpc3-external-ip" {
  value = yandex_compute_instance.vpc3.network_interface.0.nat_ip_address
}
output "access_key" {
  value = yandex_iam_service_account_static_access_key.sa-key.access_key
  sensitive = true
}
output "secret_key" {
  value = yandex_iam_service_account_static_access_key.sa-key.secret_key
  sensitive = true
}

