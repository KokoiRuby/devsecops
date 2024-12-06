## tecent cloud ##

# export TF_VAR_secret_id="..."
# export TF_VAR_secret_key=".."
variable "secret_id" {
  default = ""
}

variable "secret_key" {
  default = ""
}

# cvm
variable "region" {
  default = "ap-hongkong"
}

variable "availability-zone" {
  default = "ap-hongkong-2"
}

variable "password" {
  default = "qwe123ewq"
}

# k3s
variable "server_name" { 
  default = "k3s"
}