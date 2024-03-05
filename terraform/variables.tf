variable "vpc_name" {
  type        = string
  default     = "diplom"
  description = "VPC network for 15.1"
}

variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "default_zone" {
  type = string
}

variable "zone-a" {
  type    = string
  default = "ru-central1-a"
}

variable "zone-b" {
  type    = string
  default = "ru-central1-b"
}

variable "zone-d" {
  type    = string
  default = "ru-central1-d"
}
variable "cloud_id" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "folder_id" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "ssh_adm_key" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "platform" {
  type    = string
  default = "standard-v2"
}
variable "public_cidr_a" {
  type        = list(string)
  default     = ["10.10.10.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "public_cidr_b" {
  type        = list(string)
  default     = ["10.10.20.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "public_cidr_d" {
  type        = list(string)
  default     = ["10.10.30.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "sa" {
  type = string
}

variable "root_user" {
  type    = string
  default = "ubuntu"
}

variable "vm_user" {
  type    = string
  default = "ubuntu"
}