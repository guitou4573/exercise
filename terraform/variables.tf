variable "environment" {
  type    = string
  default = "development"
}

variable "region" {
  type    = string
  default = "us-west-1"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-west-1a", "us-west-1b"]
}