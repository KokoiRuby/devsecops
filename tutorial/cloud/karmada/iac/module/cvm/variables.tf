# Tencent Cloud variables.

variable "secret_id" {
  default = ""
}

variable "secret_key" {
  default = ""
}

variable "region" {
  default = ""
}

variable "availability_zone" {
  default = ""
}

variable "instance_charge_type" {
  default = "SPOTPAID"
}

variable "tags" {
  type = map(string)

  default = {
    # key = "value"
  }
}

variable "image_id" {
  default = ""
}

variable "instance_name" {
  default = "tf-cvm"
}

variable "password" {
  default = ""
}

variable "cpu" {
  default = ""
}

variable "memory" {
  default = ""
}

variable "vpc_id" {
  default = ""
}

variable "subnet_id" {
  default = ""
}

variable "sg_id" {
  default = ""
}
