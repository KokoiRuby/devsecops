provider "tencentcloud" {
  secret_id  = var.secret_id
  secret_key = var.secret_key
  region     = var.region
}

resource "tencentcloud_vpc" "vpc" {
  name       = "tf_vpc_default"
  cidr_block = "10.96.0.0/16"
}

resource "tencentcloud_subnet" "subnet" {
  name              = "tf_subnet_default"
  vpc_id            = tencentcloud_vpc.vpc.id
  availability_zone = var.availability_zone
  cidr_block        = "10.96.1.0/24"
}

resource "tencentcloud_route_table" "route_table" {
  name   = "tf-default-rt"
  vpc_id = tencentcloud_vpc.vpc.id
}

# security group
resource "tencentcloud_security_group" "sg" {
  name        = "sg"
}

resource "tencentcloud_security_group_lite_rule" "all" {
  security_group_id = tencentcloud_security_group.sg.id

  ingress = [
    "ACCEPT#0.0.0.0/0#ALL#TCP",
  ]

  egress = [
    "ACCEPT#0.0.0.0/0#ALL#TCP",
  ]
}

# resource "tencentcloud_security_group_rule_set" "sg_rs" {
#   security_group_id = tencentcloud_security_group.sg.id

#   egress {
#     action      = "ACCEPT"
#     cidr_block  = "0.0.0.0/0"
#     description = "any"
#   }

#   ingress {
#     action      = "ACCEPT"
#     cidr_block  = "0.0.0.0/0"
#     protocol    = "ICMP"
#     description = "icmp"
#   }

#   ingress {
#     action      = "ACCEPT"
#     cidr_block  = "0.0.0.0/0"
#     protocol    = "TCP"
#     port        = "80"
#     description = "http"
#   }

#   ingress {
#     action      = "ACCEPT"
#     cidr_block  = "0.0.0.0/0"
#     protocol    = "TCP"
#     port        = "443"
#     description = "https"
#   }

#   ingress {
#     action      = "ACCEPT"
#     cidr_block  = "0.0.0.0/0"
#     protocol    = "TCP"
#     port        = "6443"
#     description = "k8s"
#   }

#   ingress {
#     action      = "ACCEPT"
#     cidr_block  = "0.0.0.0/0"
#     protocol    = "TCP"
#     port        = "22"
#     description = "ssh"
#   }

#   ingress {
#     action      = "ACCEPT"
#     cidr_block  = "0.0.0.0/0"
#     protocol    = "TCP"
#     port        = "22"
#     description = "ssh"
#   }

#   # after install gitlab, nginx-controller will listen on 22
#   ingress {
#     action      = "ACCEPT"
#     cidr_block  = "0.0.0.0/0"
#     protocol    = "TCP"
#     port        = "2222"
#     description = "ssh_login"
#   }

#   ingress {
#     action      = "ACCEPT"
#     cidr_block  = "0.0.0.0/0"
#     protocol    = "TCP"
#     port        = "3000"
#     description = "grafana"
#   }
# }