variable "cf_api_token" {
  type      = string
  sensitive = true
}

variable "account_id" {
  type = string
}

variable "project" {
  type = string
  default = "www"
}

variable "zone" {
  type = string
  default = "yifen9.li"
}

variable "production_branch" {
  type    = string
  default = "main"
}