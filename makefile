# Set default no argument goal to help
.DEFAULT_GOAL := help

# Ensure that errors don't hide inside pipes
SHELL         = /bin/bash
.SHELLFLAGS   = -o pipefail -c

# For cleanup, get Compose project name from .env file
DC_PROJECT?=$(shell cat .env | sed 's/^*=//')

# Every command is a PHONY, to avoid file naming confliction -> strengh comes from good habits!
.PHONY: help
help:
	@echo "=============================================================================="
	@echo " Geospatial Metadata Catalogue complete SDI  https://github.com/elasticlabs/teamengine-compose "
	@echo " "
	@echo "Hints for developers:"
	@echo "  make proxy-up               # Initialize front proxy entrypoint"
	@echo "  make build-ets              # Build OGC Web services ETS"
	@echo "  make build                  # Makes container & volumes cleanup, and builds TEAMEngine"
	@echo "  make up                     # With working proxy, brings up the testing infrastructure"
	@echo "  make update                 # Update the whole stack"
	@echo "=============================================================================="

.PHONY: proxy-up
proxy-up:
	chmod 755 proxy-toolkit/uploadsize.conf
	docker-compose -f docker-compose.proxy.yml up -d --build --remove-orphans portainer 

.PHONY: up
up:
	#docker-compose up -d --remove-orphans teamengine
    docker-compose -f docker-compose.yml up -d portainer

.PHONY: build-ets
build:
	# Maven build ETS test suites

.PHONY: build
build:
	# Maven build TEAMEngine
	docker-compose -f docker-compose.yml --build teamengine

.PHONY: update
update: pull up wait
	docker image prune

.PHONY: wait
wait: 
	sleep 5