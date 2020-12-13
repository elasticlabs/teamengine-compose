# Set default no argument goal to help
.DEFAULT_GOAL := help

# Ensure that errors don't hide inside pipes
SHELL         = /bin/bash
.SHELLFLAGS   = -o pipefail -c

# For cleanup, get Compose project name from .env file
DC_PROJECT?=$(shell cat .env | sed 's/.*=//')

# Every command is a PHONY, to avoid file naming confliction.
.PHONY: help
help:
	@echo "==================================================================================="
	@echo "              TEAMEngine OGC Web services test orchestration "
	@echo "            https://github.com/elasticlabs/teamengine-compose "
	@echo " "
	@echo "Hints for developers:"
	@echo "  make build         # Makes container & volumes cleanup, and builds TEAMEngine"
	@echo "  make up            # With working proxy, brings up the testing infrastructure"
	@echo "  make update        # Update the whole stack"
	@echo "  make hard-cleanup  # Hard cleanup of images, containers, networks, volumes & data"
	@echo "==================================================================================="

.PHONY: up
up: 
	git stash && git pull
	docker-compose -f docker-compose.yml up -d --build --remove-orphans

.PHONY: build
build:
	docker-compose -f docker-compose.yml build teamengine
 
.PHONY: update
update: 
	docker-compose -f docker-compose.yml pull teamengine
	docker-compose -f docker-compose.yml up -d --build 	

.PHONY: hard-cleanup
hard-cleanup:
	@echo "[INFO] Bringing done the TEAMEngine stack"
	docker-compose -f docker-compose.yml down --remove-orphans
	# 2nd : clean up all containers & images, without deleting static volumes
	@echo "[INFO] Cleaning up containers & images"
	docker system prune -a
	# Delete all hosted persistent data available in volumes
	@echo "[INFO] Cleaning up static volumes"
	docker volume rm -f $(DC_PROJECT)_te-webapp
	# Remove all dangling docker volumes
	@echo "[INFO] Remove all dangling docker volumes"
	docker volume rm $(shell docker volume ls -qf dangling=true)

.PHONY: wait
wait: 
	sleep 5