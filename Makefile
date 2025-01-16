.PHONY: dev build init-db reset-db load-fixtures db-stats help

# Colors
YELLOW := \033[1;33m
GREEN := \033[0;32m
NC := \033[0m

# Default target
.DEFAULT_GOAL := help

dev: ## Start development server
	@npm run dev

build: ## Build for production
	@npm run build

init-db: ## Initialize database with schema
	@chmod +x scripts/init-db.sh
	@./scripts/init-db.sh

reset-db: ## Reset database and load fixtures (requires confirmation)
	@chmod +x scripts/reset-db.sh
	@./scripts/reset-db.sh

load-fixtures: ## Load sample data into database
	@chmod +x scripts/load-fixtures.sh
	@./scripts/load-fixtures.sh

db-stats: ## Show database statistics
	@chmod +x scripts/show-db-stats.sh
	@./scripts/show-db-stats.sh

help: ## Show this help
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
