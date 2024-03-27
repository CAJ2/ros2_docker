#!/usr/bin/env bash
set -eo pipefail

# This script attaches a terminal to a running dev container.
# It matches containers using the current git directory name.
# This also allows multiple dev containers using git worktree.
gitdir=$(git rev-parse --show-toplevel)
gitbase=`basename ${gitdir}`
devcontainers=$(docker ps --format '{{.Names}}' | grep "${gitbase}-dev" || true)
if [ -z "$devcontainers" ]; then
  echo "No dev containers are running."
  exit 1
fi
docker exec -it `echo "${devcontainers}" | head -1` /bin/bash
