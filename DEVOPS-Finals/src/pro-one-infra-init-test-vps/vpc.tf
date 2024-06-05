resource "yandex_compute_instance" "vpc" {
  name = "vpc"
  zone = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd84rmelvcpjp2jpo1gq"
      size = 20
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-a.id
    nat        = true
  }

  metadata = {
    user-data = "${file("secret.txt")}"
  }
}

resource "yandex_compute_instance" "vpc2" {
  name = "vpc2"
  zone = "ru-central1-b"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd84rmelvcpjp2jpo1gq"
      size = 15
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-b.id
    nat        = true
  }

  metadata = {
    user-data = "${file("secret.txt")}"
  }
}


resource "yandex_compute_instance" "vpc3" {
  name = "vpc3"
  zone = "ru-central1-b"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd84rmelvcpjp2jpo1gq"
      size = 15
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-c.id
    nat        = true
  }

  metadata = {
    user-data = "${file("secret.txt")}"
  }
}

