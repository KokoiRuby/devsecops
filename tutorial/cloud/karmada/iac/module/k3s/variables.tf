variable "server_name" {
  default = "tf-k3s"
}

variable "public_ip" {
  default = ""
}

variable "private_ip" {
  default = ""
}

variable "user" {
  default = "ubuntu"
}

variable "password" {
  default = ""
}

variable "pod_cidr" {
  default = ""
}

variable "service_cidr" {
  default = ""
}