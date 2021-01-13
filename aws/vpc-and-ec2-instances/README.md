# AWS VPC + EC2 instances

This Terraform module can be used to create a simple VPC with a small number of
EC2 instances in the same subnet. Edit [variables.tf](variables.tf) as
needed. By default we will create 2 `a1.medium` instances (arm64) in the
`us-west-2` region, using the Amzon Linux 2 AMI.
