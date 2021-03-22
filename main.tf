resource "aws_key_pair" "example" {
  key_name   = "uberkey"
  public_key = file("/Users/sayalipathare/Documents/DevOps/UberBusModified/Infra/UberBusInfra/uberkey.pub")
}

resource "aws_instance" "uber_instance" {
  ami           = "ami-042e8287309f5df03"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.example.key_name
  tags = {
    Name = "test-instance"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.uber_instance.id
  allocation_id = "eipalloc-0c495cb2179d6e6c4"
}


resource "aws_security_group" "ssh_group" {
  name        = "ssh access group"
  description = "Allow traffic on port 22"

  tags = {
    Name = "SSH Traffic Security Group"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 3000
    to_port     = 3000
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 5000
    to_port     = 5000
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "uber_vpc" {
  cidr_block                       = "10.0.0.0/16"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  enable_classiclink_dns_support   = true
  assign_generated_ipv6_cidr_block = false
  tags = {
    Name = "Uber"
  }
}

resource "aws_subnet" "public_subnet" {
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.uber_vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "Uber public"
  }
}

resource "aws_internet_gateway" "internet_gateway_uber" {
  vpc_id = aws_vpc.uber_vpc.id
  tags = {
    Name = "Uber IG"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.uber_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway_uber.id
  }
  tags = {
    Name = "Uber RT"
  }
}

resource "aws_route_table_association" "association1" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.ssh_group.id
  network_interface_id = aws_instance.uber_instance.primary_network_interface_id
}

module "provision_project" {
  source               = "./provision_project"
  host                 = aws_instance.uber_instance.public_dns
  path_to_private_key  = "${var.path_to_private_key}"
  base_directory       = "/Users/sayalipathare/Documents/DevOps/UberBusModified/Infra/UberBusInfra"
  project_link_or_path = "foo"
  image_version        = "bar"
  use_github           = "yep"
  use_local            = "nope"
  public_ip            = aws_instance.uber_instance.public_dns
}
