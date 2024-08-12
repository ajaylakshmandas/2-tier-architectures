variable "my_region" {
    type = string
    default = "us-east-1"
  
}

variable "instancetype" {
    type = string 
    default = "t3.micro"
}

variable "count-ec2" {
    type = number
    default = 2
  
}