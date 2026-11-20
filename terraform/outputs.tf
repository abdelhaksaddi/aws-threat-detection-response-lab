output "existing_vpc_id" {
  value = data.aws_vpc.lab.id
}

output "existing_subnet_id" {
  value = data.aws_subnet.public.id
}

output "existing_ec2_instance_id" {
  value = data.aws_instance.ubuntu.id
}
