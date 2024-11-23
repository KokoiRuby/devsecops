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


## k3s ##
variable "server_name" {
  default = "k3s"
}


## cloudflare ##
# https://dash.cloudflare.com/
# https://developers.cloudflare.com/fundamentals/api/get-started/create-token/
# Permission:     Zone/Zone/Read, Zone/DNS/Edit
# Zone Resources: Include/All zones
variable "cloudflare_api_key" {
  default = ""
}

# free domain in https://register.us.kg/
variable "domain" {
  default = ""
}

variable "prefix" {
  default = "devsecops"
}

variable "ip" {
  default = ""
}

variable "records" {
  default = []
}

