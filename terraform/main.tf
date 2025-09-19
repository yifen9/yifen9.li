resource "cloudflare_pages_project" "www" {
  account_id        = var.account_id
  name              = var.project_name
  production_branch = "main"
}

resource "cloudflare_pages_domain" "root" {
  account_id   = var.account_id
  project_name = cloudflare_pages_project.www.name
  domain       = var.domain
}