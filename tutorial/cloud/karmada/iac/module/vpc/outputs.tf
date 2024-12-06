output "vpc_id" {
  value = tencentcloud_vpc.vpc.id
}

output "subnet_id" {
  value = tencentcloud_subnet.subnet.id
}

output "sg_id" {
  value = tencentcloud_security_group.sg.id
}
