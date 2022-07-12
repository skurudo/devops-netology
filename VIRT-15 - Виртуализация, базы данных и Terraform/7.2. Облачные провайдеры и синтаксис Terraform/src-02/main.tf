variable "yandex_token" {
  type        = string
  description = "Yandex Cloud API key"
}

variable "yandex_region" {
  type        = string
  description = "Yandex Cloud Region (i.e. ru-central1-a)"
}

variable "yandex_cloud_id" {
  type        = string
  description = "Yandex Cloud id"
}

variable "yandex_folder_id" {
  type        = string
  description = "Yandex Cloud folder id"
}

variable "yc_vm_cpu" {
  type = string
  description = "Yandex Instance vCPU"
}

variable "yc_vm_ram" {
  type = string
  description = "Yandex Instance RAM"
}

resource "yandex_compute_instance" "test" {
  name = "testnode72"

  resources {
    cores  = var.yc_vm_cpu
    memory = var.yc_vm_ram
  }

  boot_disk {
    initialize_params {
      image_id = "fd86r1io4rv99qvgk91n"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.my-subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_vpc_network" "my-network" {
  name = "my-network"
}

resource "yandex_vpc_subnet" "my-subnet" {
  name           = "my-subnet"
  zone           = var.yandex_region
  network_id     = yandex_vpc_network.my-network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "internal_ip_address_test_vm" {
  value = yandex_compute_instance.test.network_interface.0.ip_address
}

output "external_ip_address_test_vm" {
  value = yandex_compute_instance.test.network_interface.0.nat_ip_address
}