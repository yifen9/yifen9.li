variable "cf_api_token" {
  type      = string
  sensitive = true
}
variable "account_id" { type = string }
variable "zone_id"    { type = string }
variable "project_name" { type = string }
variable "domain" { type = string }