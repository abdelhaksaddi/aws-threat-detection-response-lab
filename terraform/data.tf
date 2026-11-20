# READ-ONLY LOOKUPS; existing infrastructure created using AWS CLI.
data "aws_vpc" "lab" {
  filter {
    name   = "tag:Name"
    values = ["security-lab-vpc"]
  }
}

data "aws_subnet" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.lab.id]
  }
  filter {
    name   = "cidr-block"
    values = ["10.0.1.0/24"]
  }
}

# Instance ID supplied by deployed AWS lab.
data "aws_instance" "ubuntu" {
  instance_id = "i-02b37eb63cdd1fc7f"
}
