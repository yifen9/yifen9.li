locals {
  project_name = replace("${var.project}.${var.zone}", ".", "-")
}

resource "cloudflare_pages_project" "this" {
  account_id        = var.account_id
  name              = local.project_name
  production_branch = var.production_branch
}