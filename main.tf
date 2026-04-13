resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "develop-a" {
  name           = var.subnet_a_name
  zone           = var.default_zone_a
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr_a
}

resource "yandex_vpc_subnet" "develop-b" {
  name           = var.subnet_b_name
  zone           = var.default_zone_b
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr_b
}


data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_image_family
}

#Platform
resource "yandex_compute_instance" "platform" {
  name        = local.web_name
  platform_id = var.vm_web_platform
  zone        = var.default_zone
  metadata    = var.vm_metadata
  resources {
    cores         = var.vm_resources.web.cores
    memory        = var.vm_resources.web.memory
    core_fraction = var.vm_resources.web.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_web_policy_preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop-a.id
    nat       = var.vm_web_network_nat
  }
}

#Platform DB
resource "yandex_compute_instance" "platform-db" {
  name        = local.db_name
  platform_id = var.vm_db_platform
  zone        = var.default_zone_b
  metadata    = var.vm_metadata
  resources {
    cores         = var.vm_resources.db.cores
    memory        = var.vm_resources.db.memory
    core_fraction = var.vm_resources.db.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_db_policy_preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop-b.id
    nat       = var.vm_web_network_nat
  }
}