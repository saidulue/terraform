resource "aws_vpc" "name" {
    cidr_block = var.cidr_block
    tags = {
        Name = var.name
    }  
}

resource "aws_subnet" "main" {
    vpc_id            = aws_vpc.name.id
    cidr_block        = var.subnet_cidr_block
    availability_zone = var.availability_zone
    tags = {
        Name = "Main-Subnet"
    }
}

resource "aws_instance" "instance_name"{ 
    ami           = var.ami_id
    instance_type = var.instance_type
    subnet_id     = aws_subnet.main.id   

    tags = {
        Name = var.instance_name
    }
      
}