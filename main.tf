provider "aws" {
  region  = "${var.region}"
}

module "consul-cluster" {
  source          = "./modules/consul"
  region          = "${var.region}"
  amisize         = "t2.micro"
  min_size        = "5"
  max_size        = "5"
  vpc_cidr        = "10.0.0.0/16"
  subnetaz1       = "${var.subnetaz1}"
  subnetaz2       = "${var.subnetaz2}"
  subnetaz3       = "${var.subnetaz3}"
  subnet_cidr1    = "10.0.1.0/24"
  subnet_cidr2    = "10.0.2.0/24"
  subnet_cidr3    = "10.0.3.0/24"
  key_name        = "consul-cluster"
  public_key_path = "${var.public_key_path}"
  asgname         = "consul-asg"
}

output "consul-dns" {
  value = "${module.consul-cluster.consul-dns}"
}
