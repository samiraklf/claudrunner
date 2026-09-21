#!/bin/bash
# Setup script for the Claude Code cloud environment that runs this repository's crew.
# Paste it into the environment's "Setup script" field at claude.ai/code.
#
# It runs once; the environment then keeps a snapshot of the disk for about seven days, so
# every run starts with all of this already installed. Running processes are not kept:
# .claudrunner/setup.sh starts the services, only when a change is about to be tested.
#
# Rules from the cloud environment: finish in under five minutes, and always exit 0 — a
# failing setup script stops every session from starting. Hence the `|| true`.
#
# /claudrunner:init fills in the parts this project needs and deletes the rest.

export DEBIAN_FRONTEND=noninteractive
REPO="/home/user/REPOSITORY"   # where the cloud session checks the repository out

# 1. System packages the image does not have. PostgreSQL 16, Redis 7, Docker, gh, jq and yq
#    are already there. Example: MySQL.
# (apt-get update -qq && apt-get install -y -qq mysql-server) || true

# 2. Container images, when the project's services only exist as images. They are kept in
#    the snapshot, so the registry is asked once a week instead of on every run.
# (dockerd >/tmp/dockerd.log 2>&1 & sleep 5; cd "$REPO" && docker compose pull db) || true

# 3. Package caches. Fill the package manager's cache, not the checkout: a run installs from
#    the cache in seconds and without the network.
# (cd "$REPO" && composer install -q --no-interaction --no-progress) || true &
# (cd "$REPO" && npm ci --no-audit --no-fund --silent) || true &
# wait

exit 0
