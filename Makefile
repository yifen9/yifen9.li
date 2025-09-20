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
CF_ACCOUNT_ID ?= $(CLOUDFLARE_ACCOUNT_ID)

.PHONY: q-preview q-build q-check q-clean deploy \
        tf-init tf-plan tf-apply tf-destroy tf-fmt tf-output

q-preview:
	cd $(SITE_DIR) && $(QUARTO) preview --host 0.0.0.0 --port $(PORT) --no-browser

q-build:
	cd $(SITE_DIR) && $(QUARTO) render

q-check:
	cd $(SITE_DIR) && $(QUARTO) check

q-clean:
	rm -rf $(OUT_DIR)

deploy:
	[ -d "$(OUT_DIR)" ] || $(MAKE) q-build PROJECT=$(PROJECT)
	$(WRANGLER) pages deploy $(OUT_DIR) --project-name $(PROJECT)-$(ZONE) --branch $(BRANCH)

tf-init:
	terraform -chdir=$(TF_DIR) init

tf-plan:
	terraform -chdir=$(TF_DIR) plan -var "account_id=$(CF_ACCOUNT_ID)" -var "project=$(PROJECT)"

tf-apply:
	terraform -chdir=$(TF_DIR) apply -auto-approve -var "account_id=$(CF_ACCOUNT_ID)" -var "project=$(PROJECT)"

tf-destroy:
	terraform -chdir=$(TF_DIR) destroy -auto-approve -var "account_id=$(CF_ACCOUNT_ID)" -var "project=$(PROJECT)"

tf-fmt:
	terraform -chdir=$(TF_DIR) fmt -recursive

tf-output:
	terraform -chdir=$(TF_DIR) output -json
