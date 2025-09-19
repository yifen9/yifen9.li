PROJECT ?= www
SITE_DIR ?= sites/$(PROJECT)
DIST ?= build
PROD_BRANCH ?= main
PREVIEW ?= 0
BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)

TF_DIR ?= terraform/pages

-include .dev.env
export

.PHONY: tf-init tf-fmt tf-validate tf-plan tf-apply tf-destroy tf-output tf-refresh tf-lock tf-providers tf-state-list deploy

tf-init:
	terraform -chdir=$(TF_DIR) init

tf-fmt:
	terraform -chdir=$(TF_DIR) fmt -recursive

tf-validate:
	terraform -chdir=$(TF_DIR) validate

tf-plan:
	terraform -chdir=$(TF_DIR) plan \
		-var="cf_api_token=$(cf_api_token)" \
		-var="account_id=$(account_id)" \
		-var="project_name=$(PROJECT)" \
		-var="production_branch=$(PROD_BRANCH)"

tf-apply:
	terraform -chdir=$(TF_DIR) apply -auto-approve \
		-var="cf_api_token=$(cf_api_token)" \
		-var="account_id=$(account_id)" \
		-var="project_name=$(PROJECT)" \
		-var="production_branch=$(PROD_BRANCH)"

tf-destroy:
	terraform -chdir=$(TF_DIR) destroy -auto-approve \
		-var="cf_api_token=$(cf_api_token)" \
		-var="account_id=$(account_id)" \
		-var="project_name=$(PROJECT)" \
		-var="production_branch=$(PROD_BRANCH)"

tf-output:
	terraform -chdir=$(TF_DIR) output

tf-refresh:
	terraform -chdir=$(TF_DIR) apply -refresh-only -auto-approve \
		-var="cf_api_token=$(cf_api_token)" \
		-var="account_id=$(account_id)" \
		-var="project_name=$(PROJECT)" \
		-var="production_branch=$(PROD_BRANCH)"

tf-lock:
	terraform -chdir=$(TF_DIR) providers lock -platform=linux_amd64 -platform=linux_arm64 -platform=darwin_amd64 -platform=darwin_arm64

tf-providers:
	terraform -chdir=$(TF_DIR) providers

tf-state-list:
	terraform -chdir=$(TF_DIR) state list

deploy:
ifeq ($(PREVIEW),1)
	wrangler pages deploy "$(SITE_DIR)/$(DIST)" --project-name "$(PROJECT)" --branch "$(BRANCH)"
else
	wrangler pages deploy "$(SITE_DIR)/$(DIST)" --project-name "$(PROJECT)" --production
endif
