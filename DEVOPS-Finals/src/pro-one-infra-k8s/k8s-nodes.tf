resource "yandex_kubernetes_node_group" "k8s-node" {
  cluster_id = yandex_kubernetes_cluster.k8s-regional.id
  name       = "k8s-workers"
  version    = "1.28"


  instance_template {
    platform_id = "standard-v2"

    metadata = {
      ssh-keys = "sku:${file("id_rsa.pub")}"
    }

    network_interface {
      nat        = true
      subnet_ids = ["${yandex_vpc_subnet.public-b.id}"]
    }

    resources {
      memory        = 4
      cores         = 2
      core_fraction = 20
    }

    boot_disk {
      type = "network-hdd"
      size = 30
    }
#    scheduling_policy {
#      preemptible = true
#    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    auto_scale {
      min     = 1
      max     = 6
      initial = 3
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-b"
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      day        = "Wednesday"
      start_time = "03:00"
      duration   = "3h"
    }
  }
}

