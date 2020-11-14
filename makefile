# Set default no argument goal to help
.DEFAULT_GOAL := help

# Ensure that errors don't hide inside pipes
SHELL         = /bin/bash
.SHELLFLAGS   = -o pipefail -c

# For cleanup, get Compose project name from .env file
DC_PROJECT?=$(shell cat .env | sed 's/^*=//')

# Every command is a PHONY, to avoid file naming confliction.
.PHONY: help
help:
	@echo "=============================================================================="
	@echo " Geospatial Metadata Catalogue complete SDI  https://github.com/elasticlabs/teamengine-compose "
	@echo " "
	@echo "Hints for developers:"
	@echo "  make build                  # Makes container & volumes cleanup, and builds TEAMEngine"
	@echo "  make up                     # With working proxy, brings up the testing infrastructure"
	@echo "  make update                 # Update the whole stack"
	@echo "  make clean                  # Do some cleanup"
	@echo "=============================================================================="

.PHONY: up
up:
    git stash && git pull
	docker-compose -f docker-compose.yml up -d --build --remove-orphans

.PHONY: build
build:
	docker-compose -f docker-compose.yml --build teamengine
 
.PHONY: update
update: 
	docker-compose -f docker-compose.yml pull 
	docker-compose -f docker-compose.yml up -d --build teamengine 	

.PHONY: clean
clean
	docker image prune
	docker container prune
	docker volume prune

.PHONY: wait
wait: 
	sleep 5