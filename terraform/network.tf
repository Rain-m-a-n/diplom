resource "yandex_vpc_network" "diplom" {
  name        = var.vpc_name
  description = "VPC Network"
}

resource "yandex_vpc_subnet" "public-a" {
  name           = "public-a"
  zone           = var.zone-a
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = var.public_cidr_a
}

resource "yandex_vpc_subnet" "public-b" {
  name           = "public-b"
  zone           = var.zone-b
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = var.public_cidr_b
}

resource "yandex_vpc_subnet" "public-d" {
  name           = "public-d"
  zone           = var.zone-d
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = var.public_cidr_d
}

resource "yandex_vpc_security_group" "nat-instance-sg" {
  name       = "sec-group"
  network_id = yandex_vpc_network.diplom.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-https"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol       = "ANY"
    description    = "local network"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = "-1"
  }
}