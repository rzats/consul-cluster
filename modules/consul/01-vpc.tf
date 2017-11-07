resource "aws_vpc" "consul-cluster" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name    = "Consul Cluster VPC"
    Project = "consul-cluster"
  }
}

resource "aws_internet_gateway" "consul-cluster" {
  vpc_id = "${aws_vpc.consul-cluster.id}"

  tags {
    Name    = "Consul Cluster IGW"
    Project = "consul-cluster"
  }
}

resource "aws_subnet" "public-a" {
  vpc_id                  = "${aws_vpc.consul-cluster.id}"
  cidr_block              = "${var.subnet_cidr1}"                       // i.e. 10.0.1.0 to 10.0.1.255
  availability_zone       = "${lookup(var.subnetaz1, var.region)}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.consul-cluster"]

  tags {
    Name    = "Consul Cluster Public Subnet"
    Project = "consul-cluster"
  }
}

resource "aws_subnet" "public-b" {
  vpc_id                  = "${aws_vpc.consul-cluster.id}"
  cidr_block              = "${var.subnet_cidr2}"                       // i.e. 10.0.2.0 to 10.0.2.255
  availability_zone       = "${lookup(var.subnetaz2, var.region)}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.consul-cluster"]

  tags {
    Name    = "Consul Cluster Public Subnet"
    Project = "consul-cluster"
  }
}

resource "aws_subnet" "public-c" {
  vpc_id                  = "${aws_vpc.consul-cluster.id}"
  cidr_block              = "${var.subnet_cidr3}"                       // i.e. 10.0.3.0 to 10.0.3.255
  availability_zone       = "${lookup(var.subnetaz3, var.region)}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.consul-cluster"]

  tags {
    Name    = "Consul Cluster Public Subnet"
    Project = "consul-cluster"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.consul-cluster.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.consul-cluster.id}"
  }

  tags {
    Name    = "Consul Cluster Public Route Table"
    Project = "consul-cluster"
  }
}

resource "aws_route_table_association" "public-a" {
  subnet_id      = "${aws_subnet.public-a.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public-b" {
  subnet_id      = "${aws_subnet.public-b.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public-c" {
  subnet_id      = "${aws_subnet.public-c.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_security_group" "consul-cluster-vpc" {
  name        = "consul-cluster-vpc"
  description = "Default security group that allows inbound and outbound traffic from all instances in the VPC"
  vpc_id      = "${aws_vpc.consul-cluster.id}"

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "Consul Cluster Internal VPC"
    Project = "consul-cluster"
  }
}

resource "aws_security_group" "consul-cluster-public-web" {
  name        = "consul-cluster-public-web"
  description = "Security group that allows web traffic from internet"
  vpc_id      = "${aws_vpc.consul-cluster.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Consul web UI
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "Consul Cluster Public Web"
    Project = "consul-cluster"
  }
}

// TODO: use a Bastion server instead of allowing public access here.
resource "aws_security_group" "consul-cluster-public-ssh" {
  name        = "consul-cluster-public-ssh"
  description = "Security group that allows SSH traffic from internet"
  vpc_id      = "${aws_vpc.consul-cluster.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "Consul Cluster Public SSH"
    Project = "consul-cluster"
  }
}
