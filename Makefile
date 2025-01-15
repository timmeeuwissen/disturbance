.PHONY: dev build init-db install clean migrate

# Development server
dev:
	yarn dev

# Production build
build:
	yarn build

# Initialize database
init-db:
	./scripts/init-db.sh

# Install dependencies
install:
	yarn install

# Clean build artifacts and dependencies
clean:
	rm -rf .nuxt
	rm -rf node_modules
	rm -rf dist
	rm -f db/disturbance.db

# Git operations
git-commit:
	./scripts/git-commit.sh

# Update changelog
update-changelog:
	./scripts/update-changelog.sh

# Default target
.DEFAULT_GOAL := dev
