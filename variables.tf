variable "region" {
  default = "us-west-2"
}

variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "subnetaz1" {
  type = "map"

  default = {
    us-east-1 = "us-east-1a"
    us-west-2 = "us-west-2a"
    eu-west-1 = "eu-west-1a"
  }
}

variable "subnetaz2" {
  type = "map"

  default = {
    us-east-1 = "us-east-1b"
    us-west-2 = "us-west-2b"
    eu-west-1 = "eu-west-1b"
  }
}

variable "subnetaz3" {
  type = "map"

  default = {
    us-east-1 = "us-east-1c"
    us-west-2 = "us-west-2c"
    eu-west-1 = "eu-west-1c"
  }
}
