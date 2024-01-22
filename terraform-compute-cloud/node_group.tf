resource "yandex_compute_image" "ubuntu-test" {
  source_family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance_group" "k8s-node" {
  name                = "k8s-node"
  folder_id           = var.folder_id
  service_account_id  = "${yandex_iam_service_account.tech-account.id}"
  deletion_protection = false
  instance_template {
    platform_id = "standard-v2"
    resources {
      memory = 2
      cores  = 2
      core_fraction = 20
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "${yandex_compute_image.ubuntu-test.id}"
        size     = 30
      }
    }

    scheduling_policy {
      preemptible = true
    }

    network_interface {
      nat = true
      network_id = "${yandex_vpc_network.my-k8s-net.id}"
      subnet_ids = ["${yandex_vpc_subnet.mysubnet-a.id}","${yandex_vpc_subnet.mysubnet-b.id}","${yandex_vpc_subnet.mysubnet-c.id}"]
    }

    metadata = {
      user-data = "#cloud-config\nusers:\n  - name: ubuntu\n    groups: sudo\n    shell: /bin/bash\n    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n    ssh-authorized-keys:\n      - ${file("~/.ssh/id_ed25519.pub")}"
    }
    network_settings {
      type = "STANDARD"
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = ["ru-central1-a","ru-central1-b","ru-central1-c"]
  }

  deploy_policy {
    max_unavailable = 3
    max_creating    = 3
    max_expansion   = 3
    max_deleting    = 3
  }
  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_member.vpc-public-admin,
    yandex_resourcemanager_folder_iam_member.images-puller,
    yandex_resourcemanager_folder_iam_member.encrypterDecrypter,
    yandex_resourcemanager_folder_iam_member.k8s-editor
  ]
}
