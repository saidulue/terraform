output "vpc_id" {
  value = aws_vpc.name.id
}
output "network_acl" {
    value = aws_vpc.name.default_network_acl_id
}
output "default_security_group" {
    value = aws_vpc.name.default_security_group_id
}
output "cidr_block" {
  value = aws_vpc.name.cidr_block
}
output "instance_id" {
    value = aws_instance.instance_name.id
}
output "public_dns" {
value = aws_instance.instance_name.public_dns

}
output "public_ip" {
value = aws_instance.instance_name.public_ip
}
output "instance_owner" {
  value = aws_instance.instance_name.arn
}
output "private_ip" {
  value = aws_instance.instance_name.private_ip
}
output "tenancy" {
  value = aws_instance.instance_name.tenancy
}