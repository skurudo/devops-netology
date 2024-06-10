resource "yandex_vpc_network" "network" {
  name = "network"
}

resource "yandex_vpc_subnet" "public-a" {
  name = "publica"
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.10.0.0/16"]
}

resource "yandex_vpc_subnet" "public-b" {
  name = "publicb"
  zone = "ru-central1-b"
  network_id = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.20.0.0/16"]
}

resource "yandex_vpc_subnet" "public-d" {
  name = "publicd"
  zone = "ru-central1-d"
  network_id = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.30.0.0/16"]
}
