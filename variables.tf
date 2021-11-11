variable "env" {}
variable "name" {}
variable "handler_path" {}
variable "node_project_path" {}

variable "attach_policy_jsons" {
  default = false
}
variable "policy_jsons" {
  default = []
}
variable "number_of_policy_jsons" {
  default = 0
}

variable "authorizer_type" {
  default = "customer"
}

variable "SERVICE_TO_SERVICE_OAUTH_CLIENT_URI" {
  default = ""
}
variable "SERVICE_TO_SERVICE_OAUTH_CLIENT_ID" {
  default = ""
}
variable "SERVICE_TO_SERVICE_OAUTH_CLIENT_SECRET" {
  default = ""
}
