resource "yandex_kubernetes_node_group" "k8s_node_group" {
  cluster_id  = "${yandex_kubernetes_cluster.k8s-regional.id}"
  name        = "test-group"
  description = "diplom"
  version     = "1.25"

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat        = true
      subnet_ids = ["${yandex_vpc_subnet.mysubnet-a.id}","${yandex_vpc_subnet.mysubnet-b.id}","${yandex_vpc_subnet.mysubnet-c.id}"]
    }

    resources {
      memory = 2
      cores  = 2
      core_fraction = 20
    }

    boot_disk {
      type = "network-hdd"
      size = 30
    }

    scheduling_policy {
      preemptible = true
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-a"
    }
    location {
      zone = "ru-central1-b"
    }
    location {
      zone = "ru-central1-c"
    }
  }

}
