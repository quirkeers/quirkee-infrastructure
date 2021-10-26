variable "env" {}
variable "name" {}

variable "handler_path" {}
variable "node_project_path" {}

variable "s3_bucket" {}

variable "api_gateway_api_execution_arn" {}
variable "attach_policy_jsons" {
  default = false
}
variable "policy_jsons" {
  default = []
}
variable "number_of_policy_jsons" {
  default = 0
}
