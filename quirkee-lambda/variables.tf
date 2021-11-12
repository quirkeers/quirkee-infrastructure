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


variable "SERVICE_TO_SERVICE_OAUTH_CLIENT_URI" {}
variable "SERVICE_TO_SERVICE_OAUTH_CLIENT_ID" {}
variable "SERVICE_TO_SERVICE_OAUTH_CLIENT_SECRET" {}

variable "AWS_S3_ACCESS_KEY" {}
variable "AWS_S3_KEY_SECRET" {}
