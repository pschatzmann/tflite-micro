#!/usr/bin/env bash
# Compiles an example sketch of this library for every board in platforms.txt.
#
# Usage: scripts/test-compile.sh [-e example] [-p platforms_file] [-s]
#   -e  example name under examples/ (default: hello_world)
#   -p  file with one FQBN per line (default: scripts/platforms.txt)
#   -s  skip boards whose core is not installed instead of failing
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."
EXAMPLE=hello_world
PLATFORMS="${SCRIPT_DIR}/platforms.txt"
SKIP_MISSING=0

while getopts "e:p:s" opt; do
  case "${opt}" in
    e) EXAMPLE="${OPTARG}" ;;
    p) PLATFORMS="${OPTARG}" ;;
    s) SKIP_MISSING=1 ;;
    *) echo "Usage: $0 [-e example] [-p platforms_file] [-s]" >&2; exit 2 ;;
  esac
done

SKETCH="${ROOT_DIR}/examples/${EXAMPLE}"
if [ ! -d "${SKETCH}" ]; then
  echo "Example not found: ${SKETCH} (run scripts/generate-docker.sh first)" >&2
  exit 2
fi

INSTALLED=$(arduino-cli core list | awk 'NR>1 {print $1}')
BUILD_DIR=$(mktemp -d)
trap 'rm -rf "${BUILD_DIR}"' EXIT

passed=(); failed=(); skipped=()
while read -r fqbn; do
  core=$(echo "${fqbn}" | cut -d: -f1,2)
  if ! grep -qx "${core}" <<< "${INSTALLED}"; then
    if [ "${SKIP_MISSING}" = 1 ]; then
      echo "SKIP ${fqbn} (core ${core} not installed)"
      skipped+=("${fqbn}")
      continue
    fi
  fi
  echo "=== ${fqbn}: ${EXAMPLE}"
  log="${BUILD_DIR}/$(echo "${fqbn}" | tr ':,=' '___').log"
  if arduino-cli compile --warnings all --library "${ROOT_DIR}" \
      --build-path "${BUILD_DIR}/$(echo "${fqbn}" | tr ':,=' '___')" \
      --fqbn "${fqbn}" "${SKETCH}" > "${log}" 2>&1; then
    grep -E "Sketch uses|Global variables" "${log}"
    passed+=("${fqbn}")
  else
    grep -E "error|Error" "${log}" | head -10
    failed+=("${fqbn}")
  fi
done < <(grep -vE '^\s*(#|$)' "${PLATFORMS}")

echo
echo "Passed:  ${#passed[@]} ${passed[*]:-}"
echo "Skipped: ${#skipped[@]} ${skipped[*]:-}"
echo "Failed:  ${#failed[@]} ${failed[*]:-}"
[ "${#failed[@]}" -eq 0 ]
