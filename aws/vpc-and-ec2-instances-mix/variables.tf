variable "region" {
  default = "us-west-2"
}

variable "windows-ami" {
  type = map

  default = {
    "us-west-2" = "ami-06c563b1f77a34281"
  }
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "subnet" {
  default = "10.0.0.0/24"
}
