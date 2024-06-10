resource "yandex_container_registry" "my-registry" {
  name = "pro-one-app"
}

resource "yandex_container_repository" "my-repository" {
  name = "${yandex_container_registry.my-registry.id}/pro-one-app"
}


# Output data
output "yandex_container_repository" {
  value = yandex_container_registry.my-registry.id
  description = "ID registry"
}


resource "null_resource" "yandex_container_repository" {
provisioner "local-exec" {
    command = "echo ${yandex_container_registry.my-registry.id} > registry-id"
 }
}
