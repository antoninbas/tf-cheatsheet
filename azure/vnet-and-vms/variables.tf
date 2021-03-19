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
  default = "vmware-inc"
}

variable "image_offer" {
  default = "tkg-capi"
}

variable "image_sku" {
  default = "k8s-1dot19dot3-ubuntu-1804"
}

variable "image_version" {
  default = "2020.12.14"
}

variable "plan_publisher" {
  default = "vmware-inc"
}

variable "plan_product" {
  default = "tkg-capi"
}

variable "plan_name" {
  default = "k8s-1dot19dot3-ubuntu-1804"
}
