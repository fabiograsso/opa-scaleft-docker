# Makefile for managing the OPA (Okta Privileged Access) lab Docker environment.
-include .env
export

COMPOSE := docker compose
LOCAL := docker compose -f docker-compose-local.yml

.DEFAULT_GOAL := help

.PHONY: help check-env \
	pull start start-live start-logs stop restart restart-logs logs ps \
	build rebuild kill clean \
	client gateway gateway-infra server1 server2 server3

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Run (public GHCR images):"
	@echo "  pull           - Pull the published images from GHCR."
	@echo "  start          - Start all containers in the background."
	@echo "  start-live     - Start all containers in the foreground (live logs)."
	@echo "  start-logs     - Start in the background and follow logs."
	@echo ""
	@echo "Run (build locally from the Dockerfiles):"
	@echo "  build          - Build all local images."
	@echo "  rebuild        - Force a rebuild from scratch (no cache, pull base)."
	@echo "  Then start with: make local-start"
	@echo ""
	@echo "Manage:"
	@echo "  stop           - Stop and remove all containers."
	@echo "  restart        - Restart all containers in the background."
	@echo "  restart-logs   - Restart in the background and follow logs."
	@echo "  logs           - Follow container logs."
	@echo "  ps             - Show container status."
	@echo "  kill           - Kill the containers and remove orphans."
	@echo "  clean          - Stop, remove containers, volumes, and orphans."
	@echo ""
	@echo "Shell into a container:"
	@echo "  client gateway gateway-infra server1 server2 server3"
	@echo ""
	@echo "Local stack:"
	@echo "  Prefix any run/manage/shell target with 'local-' to use the locally"
	@echo "  built images instead of GHCR, e.g. make local-start, make local-restart,"
	@echo "  make local-logs, make local-stop, make local-client."
	@echo ""
	@echo "First run: cp .env.example .env  and set your tokens."

check-env:
	@test -f .env || (echo "\033[0;31mERROR: .env file not found!\033[0m"; \
		echo "Copy the sample: cp .env.example .env  and set your tokens."; exit 1)

# --- Run: public (GHCR) images ---
pull:
	@echo "--> Pulling published images from GHCR..."
	@$(COMPOSE) pull

start: check-env
	@echo "--> Starting containers in detached mode..."
	@$(COMPOSE) up -d

start-live: check-env
	@echo "--> Starting containers in the foreground..."
	@$(COMPOSE) up

start-logs: check-env
	@echo "--> Starting containers and attaching logs..."
	@$(COMPOSE) up -d
	@$(MAKE) logs

# --- Run: build locally ---
build:
	@echo "--> Building all local images..."
	@$(LOCAL) build

rebuild:
	@echo "--> Forcing a rebuild of all local images..."
	@$(LOCAL) build --no-cache --pull

# --- Manage (shared project name opa-lab, works with either variant) ---
stop:
	@echo "--> Stopping containers..."
	@$(COMPOSE) down

restart: stop start

restart-logs: stop start-logs

logs:
	@echo "--> Tailing and following logs..."
	@$(COMPOSE) logs -f --tail=500

ps:
	@$(COMPOSE) ps

kill:
	@echo "--> Killing the containers and removing orphans..."
	@$(COMPOSE) kill --remove-orphans

clean:
	@echo "--> Removing containers, volumes, and orphans..."
	@$(COMPOSE) down -v --remove-orphans

# --- Shell into containers ---
client:
	@$(COMPOSE) exec client bash

gateway:
	@$(COMPOSE) exec gateway bash

gateway-infra:
	@$(COMPOSE) exec gateway-infra bash

server1:
	@$(COMPOSE) exec server1 bash

server2:
	@$(COMPOSE) exec server2 bash

server3:
	@$(COMPOSE) exec server3 bash

# Run any target against the locally-built stack, e.g. `make local-start`.
local-%:
	@$(MAKE) --no-print-directory $* COMPOSE="$(LOCAL)"
