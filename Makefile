# ---------------------------------------------------------------------------
# Kamal deployment helper — Ruby on Rails 3 (Advanced)
#
# Every exercise (ex00..ex06) is an INDEPENDENT Kamal app deployed to the SAME
# server, routed by subdomain:  ror-advanced-NN.pulgamecanica.com  ->  165.22.16.194
#
# Quick start:
#   1. Create a classic GHCR token (write:packages) and make it available:
#        echo 'export KAMAL_REGISTRY_PASSWORD=ghp_xxx' > ~/.kamal-token
#      (or just `export KAMAL_REGISTRY_PASSWORD=ghp_xxx` in your shell)
#   2. make builder                # one-time: fix buildx DNS (systemd-resolved hosts)
#   3. make setup-ex01             # first deploy of an exercise
#   4. make deploy-ex01            # subsequent releases
#
# Run `make help` for the full list.
# ---------------------------------------------------------------------------

EXERCISES    := ex00 ex01 ex02 ex03 ex04 ex05 ex06
RUBY_VERSION ?= 3.3.6
SERVER       := 165.22.16.194

# kamal must run under a host Ruby (the apps pin 3.0.2, which isn't installed
# here); prefix every invocation so rbenv doesn't choke on .ruby-version.
KAMAL := RBENV_VERSION=$(RUBY_VERSION) kamal

# Optional convenience: load the GHCR token from ~/.kamal-token if present.
# That file should contain:  export KAMAL_REGISTRY_PASSWORD=ghp_xxx
-include $(HOME)/.kamal-token
export KAMAL_REGISTRY_PASSWORD

.DEFAULT_GOAL := help

.PHONY: help builder check-token deploy-all setup-all

help:
	@echo "Kamal deploy helper — exercises: $(EXERCISES)"
	@echo ""
	@echo "  make builder             (Re)create the buildx builder with host networking"
	@echo "                           Fixes DNS timeouts on systemd-resolved hosts."
	@echo ""
	@echo "  Per exercise (replace exNN, e.g. ex03):"
	@echo "    make setup-exNN        First deploy: bootstrap docker + proxy + db + app"
	@echo "    make deploy-exNN       Build, push, release a new version"
	@echo "    make redeploy-exNN     Rebuild + redeploy without re-bootstrapping"
	@echo "    make seed-exNN         Run db:seed on the server"
	@echo "    make logs-exNN         Tail the app logs"
	@echo "    make console-exNN      Rails console on the server"
	@echo "    make info-exNN         Show container/version details"
	@echo "    make remove-exNN       Tear the exercise down (containers + proxy entry)"
	@echo ""
	@echo "    make setup-all         setup every exercise (heavy on a 2GB box!)"
	@echo "    make deploy-all        deploy every exercise"
	@echo ""
	@echo "  Requires KAMAL_REGISTRY_PASSWORD (classic GHCR PAT, write:packages)."

# Fix the classic buildx DNS problem: on hosts using systemd-resolved
# (127.0.0.53), the docker-container builder can't resolve registries. Sharing
# the host network namespace lets it reach the stub resolver.
builder:
	-docker buildx rm kamal-local-docker-container 2>/dev/null || true
	docker buildx create --name kamal-local-docker-container \
		--driver docker-container --driver-opt network=host --bootstrap
	@echo "Builder ready (network=host)."

check-token:
	@if [ -z "$$KAMAL_REGISTRY_PASSWORD" ]; then \
		echo "ERROR: KAMAL_REGISTRY_PASSWORD is not set."; \
		echo "  A classic GHCR PAT with write:packages is required (the gh CLI"; \
		echo "  'gho_' token is rejected by GHCR)."; \
		echo "    export KAMAL_REGISTRY_PASSWORD=ghp_xxx"; \
		echo "  or put 'export KAMAL_REGISTRY_PASSWORD=ghp_xxx' in ~/.kamal-token"; \
		exit 1; \
	fi

# Generate the per-exercise targets.
define EX_RULES
.PHONY: setup-$(1) deploy-$(1) redeploy-$(1) seed-$(1) logs-$(1) console-$(1) info-$(1) remove-$(1)

setup-$(1): check-token
	cd $(1)/acme && $(KAMAL) setup

deploy-$(1): check-token
	cd $(1)/acme && $(KAMAL) deploy

redeploy-$(1): check-token
	cd $(1)/acme && $(KAMAL) redeploy

seed-$(1): check-token
	cd $(1)/acme && $(KAMAL) app exec --reuse "bin/rails db:seed"

logs-$(1):
	cd $(1)/acme && $(KAMAL) app logs -f

console-$(1):
	cd $(1)/acme && $(KAMAL) app exec -i --reuse "bin/rails console"

info-$(1):
	cd $(1)/acme && $(KAMAL) details

remove-$(1): check-token
	cd $(1)/acme && $(KAMAL) remove -y
endef

$(foreach ex,$(EXERCISES),$(eval $(call EX_RULES,$(ex))))

# Aggregates.
setup-all:  $(addprefix setup-,$(EXERCISES))
deploy-all: $(addprefix deploy-,$(EXERCISES))
