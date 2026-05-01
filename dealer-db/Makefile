# =====================================================
# MAKEFILE — DEALER MANAGEMENT SYSTEM DATABASE
# =====================================================
# Engine : PostgreSQL 16
# Tool   : golang-migrate (go-migrate)
# Pattern: Multi-schema × multi-track (table/function/trigger/seed)
# =====================================================

NO_COLOR  = \033[0m
OK_COLOR  = \033[32;01m
WARN_COLOR= \033[33;01m
ERR_COLOR = \033[31;01m
INFO_COLOR= \033[36;01m

# Load .env
ifneq (,$(wildcard .env))
    include .env
    export
endif

DB_HOST     ?= localhost
DB_PORT     ?= 5432
DB_NAME     ?= dealer_db
DB_USER     ?= dealer_app
DB_PASSWORD ?= dealer_dev_2025
DB_SSL_MODE ?= disable
MIGRATIONS_BASE ?= ./migrations/schema

# Schema selection (public | auth | dealer)
SCHEMA ?= public
# Track selection (table | function | trigger | seed)
TYPE   ?= table

# Derived paths
MIGRATION_PATH = $(MIGRATIONS_BASE)/$(SCHEMA)/$(TYPE)

# URL-encode password — handles special chars: @, !, #, etc.
DB_PASSWORD_ENCODED := $(shell python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1], safe=''))" "$(DB_PASSWORD)" 2>/dev/null || echo "$(DB_PASSWORD)")
DB_URL = postgresql://$(DB_USER):$(DB_PASSWORD_ENCODED)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=$(DB_SSL_MODE)

# Per-schema, per-track migration table name
# No x-migrations-table-quoted: search_path puts table into correct schema automatically
MIGRATE_TABLE = schema_migrations_$(TYPE)

# =====================================================
# VALIDATION
# =====================================================
define validate_schema
	@if [ ! -d "$(MIGRATIONS_BASE)/$(SCHEMA)" ]; then \
		echo "$(ERR_COLOR)Schema '$(SCHEMA)' not found.$(NO_COLOR)"; \
		echo "$(INFO_COLOR)Available: $$(ls $(MIGRATIONS_BASE))$(NO_COLOR)"; \
		exit 1; \
	fi
endef

define validate_type
	@if [ ! -d "$(MIGRATION_PATH)" ]; then \
		echo "$(ERR_COLOR)Type '$(TYPE)' not found in schema '$(SCHEMA)'.$(NO_COLOR)"; \
		echo "$(INFO_COLOR)Available: $$(ls $(MIGRATIONS_BASE)/$(SCHEMA))$(NO_COLOR)"; \
		exit 1; \
	fi
endef

define ensure_migrations_table
	@PGPASSWORD='$(DB_PASSWORD)' psql -h $(DB_HOST) -p $(DB_PORT) -U $(DB_USER) -d $(DB_NAME) \
		-c "CREATE SCHEMA IF NOT EXISTS $(SCHEMA);" \
		-c "CREATE TABLE IF NOT EXISTS $(SCHEMA).$(MIGRATE_TABLE) (version bigint NOT NULL, dirty boolean NOT NULL);" \
		-c "CREATE UNIQUE INDEX IF NOT EXISTS $(SCHEMA)_$(MIGRATE_TABLE)_idx ON $(SCHEMA).$(MIGRATE_TABLE) (version);" \
		> /dev/null 2>&1 || true
endef

# =====================================================
# DOCKER
# =====================================================
.PHONY: db.up db.down db.reset db.logs db.psql

db.up:
	@echo "$(OK_COLOR)Starting PostgreSQL + pgAdmin...$(NO_COLOR)"
	docker compose up -d
	@echo "$(OK_COLOR)pgAdmin: http://localhost:5050$(NO_COLOR)"

db.down:
	docker compose down

db.reset:
	@echo "$(WARN_COLOR)WARNING: This will destroy all data!$(NO_COLOR)"
	@read -p "Confirm? [y/N] " ans && [ "$$ans" = "y" ]
	docker compose down -v
	docker compose up -d

db.logs:
	docker compose logs -f postgres

db.psql:
	PGPASSWORD='$(DB_PASSWORD)' psql -h $(DB_HOST) -p $(DB_PORT) -U $(DB_USER) -d $(DB_NAME)

# =====================================================
# MIGRATION — SINGLE SCHEMA/TYPE
# =====================================================
.PHONY: migrate.up migrate.down migrate.force migrate.version migrate.status

migrate.up: ## Run migrations up. Usage: make migrate.up SCHEMA=auth TYPE=table
	$(call validate_schema)
	$(call validate_type)
	$(call ensure_migrations_table)
	@echo "$(OK_COLOR)Migrating UP: $(SCHEMA)/$(TYPE)$(NO_COLOR)"
	migrate \
		-path $(MIGRATION_PATH) \
		-database "$(DB_URL)&x-migrations-table=$(MIGRATE_TABLE)&search_path=$(SCHEMA),public" \
		up

migrate.down: ## Rollback 1 step. Usage: make migrate.down SCHEMA=auth TYPE=table
	$(call validate_schema)
	$(call validate_type)
	@echo "$(WARN_COLOR)Rolling back 1: $(SCHEMA)/$(TYPE)$(NO_COLOR)"
	migrate \
		-path $(MIGRATION_PATH) \
		-database "$(DB_URL)&x-migrations-table=$(MIGRATE_TABLE)&search_path=$(SCHEMA),public" \
		down 1

migrate.force: ## Force version. Usage: make migrate.force SCHEMA=auth TYPE=table VERSION=1
	$(call validate_schema)
	$(call validate_type)
	@if [ -z "$(VERSION)" ]; then echo "$(ERR_COLOR)VERSION required$(NO_COLOR)"; exit 1; fi
	migrate \
		-path $(MIGRATION_PATH) \
		-database "$(DB_URL)&x-migrations-table=$(MIGRATE_TABLE)&search_path=$(SCHEMA),public" \
		force $(VERSION)

migrate.version: ## Show current version. Usage: make migrate.version SCHEMA=auth TYPE=table
	$(call validate_schema)
	$(call validate_type)
	migrate \
		-path $(MIGRATION_PATH) \
		-database "$(DB_URL)&x-migrations-table=$(MIGRATE_TABLE)&search_path=$(SCHEMA),public" \
		version

migrate.status:
	@echo "$(INFO_COLOR)=== Migration Status ===$(NO_COLOR)"
	@for schema in public auth dealer; do \
		for type in table function trigger seed; do \
			dir="$(MIGRATIONS_BASE)/$$schema/$$type"; \
			if [ -d "$$dir" ] && ls "$$dir"/*.up.sql 2>/dev/null | head -1 > /dev/null; then \
				echo "  $$schema/$$type"; \
			fi; \
		done; \
	done

# =====================================================
# MIGRATION — RUN ALL (ordered)
# =====================================================
.PHONY: migrate.all migrate.all.down

migrate.all: ## Run all migrations in correct order
	@echo "$(OK_COLOR)=== Running ALL migrations ===$(NO_COLOR)"
	@$(MAKE) migrate.up SCHEMA=public TYPE=table
	@$(MAKE) migrate.up SCHEMA=public TYPE=function
	@$(MAKE) migrate.up SCHEMA=auth TYPE=table
	@$(MAKE) migrate.up SCHEMA=auth TYPE=function
	@$(MAKE) migrate.up SCHEMA=auth TYPE=trigger
	@$(MAKE) migrate.up SCHEMA=auth TYPE=seed
	@$(MAKE) migrate.up SCHEMA=dealer TYPE=table
	@$(MAKE) migrate.up SCHEMA=dealer TYPE=function
	@$(MAKE) migrate.up SCHEMA=dealer TYPE=trigger
	@$(MAKE) migrate.up SCHEMA=dealer TYPE=seed
	@echo "$(OK_COLOR)=== All migrations complete ===$(NO_COLOR)"

migrate.all.down: ## Rollback everything (DESTRUCTIVE)
	@echo "$(ERR_COLOR)WARNING: Rolling back ALL migrations!$(NO_COLOR)"
	@read -p "Confirm? [y/N] " ans && [ "$$ans" = "y" ]
	@for schema in dealer auth public; do \
		for type in seed trigger function table; do \
			dir="$(MIGRATIONS_BASE)/$$schema/$$type"; \
			if [ -d "$$dir" ] && ls "$$dir"/*.up.sql 2>/dev/null | head -1 > /dev/null; then \
				$(MAKE) migrate.down SCHEMA=$$schema TYPE=$$type || true; \
			fi; \
		done; \
	done

# =====================================================
# GENERATE NEW MIGRATION FILE
# =====================================================
.PHONY: gen.migration

gen.migration: ## Create new migration. Usage: make gen.migration SCHEMA=dealer TYPE=table name=add_something
	$(call validate_schema)
	@if [ -z "$(name)" ]; then echo "$(ERR_COLOR)'name' required. Usage: make gen.migration SCHEMA=dealer TYPE=table name=add_something$(NO_COLOR)"; exit 1; fi
	migrate create -ext sql -dir $(MIGRATIONS_BASE)/$(SCHEMA)/$(TYPE) -seq $(name)
	@echo "$(OK_COLOR)Created migration files in $(MIGRATIONS_BASE)/$(SCHEMA)/$(TYPE)$(NO_COLOR)"

# =====================================================
# TOOLS
# =====================================================
.PHONY: install.tools check.tools

install.tools:
	@echo "$(INFO_COLOR)Installing golang-migrate...$(NO_COLOR)"
	go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest
	@echo "$(OK_COLOR)Done. Run 'migrate --version' to verify.$(NO_COLOR)"

check.tools:
	@command -v migrate > /dev/null 2>&1 && echo "$(OK_COLOR)migrate: $$(migrate --version)$(NO_COLOR)" || echo "$(ERR_COLOR)migrate: NOT FOUND — run: make install.tools$(NO_COLOR)"
	@command -v docker > /dev/null 2>&1 && echo "$(OK_COLOR)docker: OK$(NO_COLOR)" || echo "$(ERR_COLOR)docker: NOT FOUND$(NO_COLOR)"
	@command -v psql > /dev/null 2>&1 && echo "$(OK_COLOR)psql: OK$(NO_COLOR)" || echo "$(ERR_COLOR)psql: NOT FOUND$(NO_COLOR)"

# =====================================================
# PRISMA (run from apps/web/)
# =====================================================
.PHONY: prisma.pull prisma.generate

prisma.pull:
	@echo "$(INFO_COLOR)Introspecting DB → Prisma schema...$(NO_COLOR)"
	cd ../apps/web && DATABASE_URL="$(DB_URL)" npx prisma db pull
	cd ../apps/web && npx prisma generate

prisma.generate:
	cd ../apps/web && npx prisma generate

# =====================================================
# HELP
# =====================================================
.PHONY: help
help:
	@echo "$(INFO_COLOR)Dealer DB — Available Commands$(NO_COLOR)"
	@echo ""
	@echo "  $(OK_COLOR)Docker$(NO_COLOR)"
	@echo "    make db.up                          Start Postgres + pgAdmin"
	@echo "    make db.down                        Stop containers"
	@echo "    make db.reset                       Destroy & restart (data loss!)"
	@echo "    make db.psql                        Open psql shell"
	@echo ""
	@echo "  $(OK_COLOR)Migrations$(NO_COLOR)"
	@echo "    make migrate.all                    Run ALL migrations in order"
	@echo "    make migrate.up SCHEMA=auth TYPE=table   Run specific track"
	@echo "    make migrate.down SCHEMA=auth TYPE=table Rollback 1 step"
	@echo "    make migrate.version SCHEMA=auth TYPE=table"
	@echo "    make migrate.status                 List all tracks"
	@echo ""
	@echo "  $(OK_COLOR)Generate$(NO_COLOR)"
	@echo "    make gen.migration SCHEMA=dealer TYPE=table name=add_promo  New migration files"
	@echo ""
	@echo "  $(OK_COLOR)Tools$(NO_COLOR)"
	@echo "    make check.tools                    Verify required tools installed"
	@echo "    make install.tools                  Install golang-migrate"
	@echo "    make prisma.pull                    Introspect DB → update Prisma schema"
