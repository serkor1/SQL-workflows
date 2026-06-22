.PHONY: init
init: ## Initialize the data
	@chmod +x scripts/*.sh
	@scripts/initialize.sh