variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"

}
variable "volume_type" {
  type    = string
  default = "gp2"
  validation {
    condition     = can(regex("^[0-9A-Za-z,]+$", var.volume_type))
    error_message = "For the application_name value only a-z, A-Z and 0-9 are allowed."
  }
}
variable "encrypted_volume" {
  type    = bool
  default = false
}
variable "desired_capacity" {
    type = number
    default = 2
}
variable "max_size" {
    type = number
    default = 2
}
variable "min_size" {
    type = number
    default = 1
}
variable "var.lb_port" {
    type = number
    default = 80

}



