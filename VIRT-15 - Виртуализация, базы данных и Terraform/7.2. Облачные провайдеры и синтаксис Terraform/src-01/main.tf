resource "yandex_compute_instance" "test" {
  name = "testnode72"

  resources {
    cores  = 2
    memory = 4
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