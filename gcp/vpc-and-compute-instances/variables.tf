variable "gcp_project" {
  default = "capable-country-309500"
}

variable "prefix" {
  default = "test"
}

variable "region" {
  default = "us-west1"
}

variable "zone" {
  default = "us-west1-a"
}

variable "instance_image" {
  default = "cos-cloud/cos-stable"
}

variable "instance_count" {
  default = "2"
}

variable "instance_type" {
  default = "e2-medium"
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "sshuser" {
  default = "antonin_bas_gmail_com"
}