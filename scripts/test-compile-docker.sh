#!/usr/bin/env bash
# Runs scripts/tools/test-compile.sh inside a container with pinned Arduino cores.
# Arguments are passed through (-e example, -p platforms_file).
# Usage: scripts/test-compile-docker.sh [-e example] [-p platforms_file]
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE=tflite-micro-arduino-test

# Build context is the repo root so scripts/cores.txt can be copied in.
docker build -f "${ROOT_DIR}/scripts/docker/Dockerfile.test" -t "${IMAGE}" "${ROOT_DIR}"
# Repo is mounted read-only; only the cores baked into the image are used.
docker run --rm \
  --user "$(id -u):$(id -g)" -e HOME=/tmp \
  -v "${ROOT_DIR}:/work:ro" \
  "${IMAGE}" "$@"
