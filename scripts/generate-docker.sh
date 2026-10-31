#!/usr/bin/env bash
# Runs scripts/tools/generate.sh inside a container so upstream code is not executed
# on the host. Usage: scripts/generate-docker.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE=tflite-micro-arduino-generator

docker build -t "${IMAGE}" "${ROOT_DIR}/scripts/docker"
# Only the repo is mounted; run as the host user so output is not root-owned.
docker run --rm \
  --user "$(id -u):$(id -g)" \
  -e HOME=/tmp -e GIT_CONFIG_COUNT=1 -e GIT_CONFIG_KEY_0=safe.directory -e GIT_CONFIG_VALUE_0='*' \
  -e KEEP_TEMP="${KEEP_TEMP:-}" \
  -v "${ROOT_DIR}:/work" \
  "${IMAGE}"
