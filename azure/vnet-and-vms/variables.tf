variable "prefix" {
  default = "test"
}

variable "region" {
  default = "West US2"
}

variable "instance_count" {
  default = "2"
}

variable "instance_size" {
  default = "Standard_F4s_v2"
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "subnet" {
  default = "10.0.0.0/24"
}

variable "enable_accelerated_networking" {
  default = true
}

variable "image_publisher" {
  default = "Canonical"
}

variable "image_offer" {
  default = "UbuntuServer"
}

variable "image_sku" {
  default = "18.04-LTS"
}

variable "image_version" {
  default = "18.04.202103151"
}
