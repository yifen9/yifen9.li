SHELL := /bin/bash

PROJECT ?= www
ZONE ?= yifen9-li
SITE_DIR := sites/$(PROJECT)
OUT_DIR ?= $(SITE_DIR)/build
PORT ?= 8080
BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)

QUARTO ?= quarto
WRANGLER ?= wrangler

TF_DIR ?= terraform
CF_ACCOUNT_ID ?= $(TF_account_id)
CF_API_TOKEN ?= $(TF_cf_api_token)

.PHONY: q-preview q-build q-check q-clean deploy \
        tf-init tf-plan tf-apply tf-destroy tf-fmt tf-output

q-preview:
	cd $(SITE_DIR) && $(QUARTO) preview --host 0.0.0.0 --port $(PORT) --no-browser

q-preview-www:
	$(MAKE) q-preview PROJECT=www

q-preview-blog:
	$(MAKE) q-preview PROJECT=blog

q-build:
	cd $(SITE_DIR) && $(QUARTO) render

q-check:
	cd $(SITE_DIR) && $(QUARTO) check

q-clean:
	rm -rf $(OUT_DIR)

deploy:
	$(MAKE) q-build PROJECT=$(PROJECT)
	$(WRANGLER) pages deploy $(OUT_DIR) --project-name $(PROJECT)-$(ZONE) --branch $(BRANCH)

deploy-www:
	$(MAKE) q-build PROJECT=www
	$(WRANGLER) pages deploy $(OUT_DIR) --project-name $(PROJECT)-$(ZONE) --branch $(BRANCH)

deploy-blog:
	$(MAKE) q-build PROJECT=blog
	$(WRANGLER) pages deploy $(OUT_DIR) --project-name $(PROJECT)-$(ZONE) --branch $(BRANCH)

tf-init:
	terraform -chdir=$(TF_DIR) init

tf-plan:
	terraform -chdir=$(TF_DIR) plan -var "account_id=$(CF_ACCOUNT_ID)" -var "cf_api_token=$(CF_API_TOKEN)" -var "project=$(PROJECT)"

tf-plan-www:
	terraform -chdir=$(TF_DIR) plan -var "account_id=$(CF_ACCOUNT_ID)" -var "project=www"

tf-plan-blog:
	terraform -chdir=$(TF_DIR) plan -var "account_id=$(CF_ACCOUNT_ID)" -var "project=blog"

tf-apply:
	terraform -chdir=$(TF_DIR) apply -auto-approve -var "account_id=$(CF_ACCOUNT_ID)" -var "cf_api_token=$(CF_API_TOKEN)" -var "project=$(PROJECT)"

tf-apply-www:
	terraform -chdir=$(TF_DIR) apply -auto-approve -var "account_id=$(CF_ACCOUNT_ID)" -var "project=www"

tf-apply-blog:
	terraform -chdir=$(TF_DIR) apply -auto-approve -var "account_id=$(CF_ACCOUNT_ID)" -var "project=blog"

tf-destroy:
	terraform -chdir=$(TF_DIR) destroy -auto-approve -var "account_id=$(CF_ACCOUNT_ID)" -var "project=$(PROJECT)"

tf-destroy-www:
	terraform -chdir=$(TF_DIR) destroy -auto-approve -var "account_id=$(CF_ACCOUNT_ID)" -var "project=www"

tf-destroy-blog:
	terraform -chdir=$(TF_DIR) destroy -auto-approve -var "account_id=$(CF_ACCOUNT_ID)" -var "project=blog"

tf-fmt:
	terraform -chdir=$(TF_DIR) fmt -recursive

tf-output:
	terraform -chdir=$(TF_DIR) output -json
