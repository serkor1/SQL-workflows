.PHONY: init
init: ## Initialize the data
	@chmod +x development/scripts/*.sh
	@development/scripts/initialize.sh