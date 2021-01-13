variable "region" {
  default = "us-west-2"
}

variable "ami" {
  type = map

  default = {
    "us-west-2" = "ami-0bdfb42effc4b150f"
  }
}

variable "instance_count" {
  default = "2"
}

variable "instance_type" {
  default = "a1.medium"
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "subnet" {
  default = "10.0.0.0/24"
}
