variable "cidr_block" {
    description = "The CIDR block for the VPC"
    type        = string
    default     = ""
  
}
variable "name" {
    description = "The name of the VPC"
    type        = string
    default     = ""
  
}
variable "ami_id" {
    description = "The AMI ID for the EC2 instance"
    type        = string
    default     = ""
  
}
variable "instance_type" {
    description = "The instance type for the EC2 instance"
    type        = string
    default     = ""
  
}
variable "subnet_id" {
    description = "The subnet ID for the EC2 instance"
    type        = string
    default     = ""
  
}
variable "subnet_cidr_block" {
    description = "The CIDR block for the subnet"
    type        = string
    default     = ""
  
}
variable "availability_zone" {
    description = "The availability zone for the subnet"
    type        = string
    default     = ""
  
}
variable "instance_name" {
    description = "The name of the EC2 instance"
    type        = string
    default     = ""
  
}