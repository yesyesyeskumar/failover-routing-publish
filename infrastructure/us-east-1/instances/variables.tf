
variable instance_profile_name {
  type = string
}

variable private_sg_id {
  default = ""
}


variable "priv_subnet_ids" {
    default = []
}

variable public_subnet_ids {
  default = []
}

variable lb_sg_id {
  default = ""
}

variable vpc_id {
  default = ""
}