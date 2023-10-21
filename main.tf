###PROVIDER###
provider "aws" {
  access_key = "aws_access_key"
  secret_key = "aws_secret_key"
  region     = "us-east-1"
  #profile = "Admin"
}

###VPC###
resource "aws_vpc" "dep51vpc" {
  cidr_block       = "10.0.0.0/16"
  
  tags = {
    Name = "Dep5.1vpc"
  }
}

###SUBNET1###
resource "aws_subnet" "PublicSubnet1" {
  vpc_id     = aws_vpc.dep51vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a" 
 

  tags = {
    Name = "D5.1_Public_Subnet_1"
  }
}

###SUBNET2###
resource "aws_subnet" "PublicSubnet2" {
  vpc_id     = aws_vpc.dep51vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b" 
 

  tags = {
    Name = "D5.1_Public_Subnet_2"
  }
}

###INSTANCE1###
resource "aws_instance" "Server01" {
  ami                    = "ami-08c40ec9ead489470"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.Dep5_SG.id]
  associate_public_ip_address = true
  key_name = "Dep5.1KeyPair"
  user_data = file("deploy.sh")
  subnet_id     = aws_subnet.PublicSubnet1.id
  tags = {
    "Name" : "Dep5.1_Jenkins_Server"
  }
}

###INSTANCE2###
resource "aws_instance" "Server02" {
  ami           = "ami-08c40ec9ead489470" 
  instance_type = "t2.micro"    
  subnet_id     = aws_subnet.PublicSubnet1.id
  vpc_security_group_ids = [aws_security_group.Dep5_SG.id]
  associate_public_ip_address = true
  key_name = "Dep5.1KeyPair"
  user_data = file("deploy2.sh")
  tags = {
    "Name" : "Dep5.1_2nd_Server"
  }
}

###INSTANCE3###
resource "aws_instance" "Server03" {
  ami           = "ami-08c40ec9ead489470" 
  instance_type = "t2.micro"    
  subnet_id     = aws_subnet.PublicSubnet2.id
  vpc_security_group_ids = [aws_security_group.Dep5_SG.id]
  key_name = "Dep5.1KeyPair"
  associate_public_ip_address = true
  user_data = file("deploy2.sh")
  tags = {
    "Name" : "Dep5.1_3rd_Server"
  }
}

###INTERNETGATEWAY###
resource "aws_internet_gateway" "D5GATEWAY" {
  vpc_id = aws_vpc.dep51vpc.id

  tags = {
    Name = "GW_d5.1"
  }
}

###ROUTETABLE###

resource "aws_route_table" "D51ROUTE" {
  vpc_id = aws_vpc.dep51vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.D5GATEWAY.id
  }
}

###SECURITYGROUP###
resource "aws_security_group" "Dep5_SG" {
  name        = "Dep5_SG"
  description = "open ssh traffic"
  vpc_id      = aws_vpc.dep51vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

tags = {
    "Name" : "Deployment_5_Security_Group"
    "Terraform" : "true"
  }

}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.PublicSubnet1.id
  route_table_id = aws_route_table.D51ROUTE.id
}


resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.PublicSubnet2.id
  route_table_id = aws_route_table.D51ROUTE.id
}

