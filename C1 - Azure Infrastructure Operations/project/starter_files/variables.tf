# variable "resource_group" {
#   type = string
#   default = "udacity"
# }
variable "tags" {
  description = "Tags to apply on resource"
  type        = map(string)
  default = {
    "Project" = "Udacity"
  }
}

variable "number_vms" {
  type = number
  default = 1
}