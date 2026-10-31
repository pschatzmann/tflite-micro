#!/usr/bin/env bash
# Generates the Arduino library (src/, library.properties) from upstream
# tensorflow/tflite-micro. Normally run through scripts/generate-docker.sh.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${SCRIPT_DIR}/.."
ROOT_DIR="${SCRIPTS_DIR}/.."
CONFIG_DIR="${SCRIPTS_DIR}"
# shellcheck source=../config.env
source "${CONFIG_DIR}/config.env"

TEMP_DIR=$(mktemp -d)
if [ -z "${KEEP_TEMP:-}" ]; then trap 'rm -rf "${TEMP_DIR}"' EXIT; else echo "Keeping ${TEMP_DIR}"; fi

echo "Cloning tflite-micro (${UPSTREAM_REF})"
git clone --depth 1 --branch "${UPSTREAM_REF}" \
  https://github.com/tensorflow/tflite-micro.git "${TEMP_DIR}/tflite-micro" 2>/dev/null ||
  { git clone https://github.com/tensorflow/tflite-micro.git "${TEMP_DIR}/tflite-micro" &&
    git -C "${TEMP_DIR}/tflite-micro" checkout "${UPSTREAM_REF}"; }
UPSTREAM_SHA=$(git -C "${TEMP_DIR}/tflite-micro" rev-parse --short HEAD)

BASE_DIR="${TEMP_DIR}/tflm_tree"
OUTPUT_DIR="${TEMP_DIR}/tflm_arduino"

(
  cd "${TEMP_DIR}/tflite-micro"
  make -f tensorflow/lite/micro/tools/make/Makefile clean_downloads
  python3 tensorflow/lite/micro/tools/project_generation/create_tflm_tree.py \
    -e hello_world \
    --makefile_options="TARGET=${TARGET} OPTIMIZED_KERNEL_DIR=${OPTIMIZED_KERNEL_DIR} TARGET_ARCH=${TARGET_ARCH}" \
    "${BASE_DIR}"
)

# Merge optimized kernel variants into the reference tree. Each variant tree is
# generated separately; only its kernel files and library are copied over.
for variant in ${MERGE_KERNEL_DIRS:-}; do
  VARIANT_DIR="${TEMP_DIR}/tflm_tree_${variant}"
  (
    cd "${TEMP_DIR}/tflite-micro"
    python3 tensorflow/lite/micro/tools/project_generation/create_tflm_tree.py \
      --makefile_options="TARGET=${TARGET} OPTIMIZED_KERNEL_DIR=${variant} TARGET_ARCH=${TARGET_ARCH}" \
      "${VARIANT_DIR}"
  )
  case "${variant}" in
    cmsis_nn)
      cp -a "${VARIANT_DIR}/tensorflow/lite/micro/kernels/cmsis_nn" "${BASE_DIR}/tensorflow/lite/micro/kernels/"
      cp -a "${VARIANT_DIR}/third_party/cmsis_nn" "${BASE_DIR}/third_party/"
      ;;
    *)
      echo "Unsupported MERGE_KERNEL_DIRS entry: ${variant}" >&2
      exit 1
      ;;
  esac
done

# Stage the hand-written overlay; create_tflm_arduino.py resolves repo paths
# relative to the current directory.
STAGE_DIR="${TEMP_DIR}/overlay"
cp -a "${SCRIPTS_DIR}/templates" "${STAGE_DIR}"
sed -e "s/@UPSTREAM_REF@/${UPSTREAM_REF} (${UPSTREAM_SHA})/" \
  "${STAGE_DIR}/library.properties.in" > "${STAGE_DIR}/library.properties"
rm "${STAGE_DIR}/library.properties.in"
# create_tflm_arduino.py invokes scripts/transform_source.py relative to cwd.
mkdir -p "${STAGE_DIR}/scripts"
cp "${SCRIPT_DIR}"/transform_source.py "${SCRIPT_DIR}"/fix_arduino_subfolders.py "${STAGE_DIR}/scripts/"

(
  cd "${STAGE_DIR}"
  python3 "${SCRIPT_DIR}/create_tflm_arduino.py" \
    --output_dir="${OUTPUT_DIR}" \
    --base_dir="${BASE_DIR}" \
    --manifest_file="${CONFIG_DIR}/MANIFEST.ini"
)

# Upstream now ships signal/ next to tensorflow/; Arduino only adds src/ to the include path.
mv "${OUTPUT_DIR}/signal" "${OUTPUT_DIR}/src/signal"

# Replace generated content (src/, examples/); hand-written repo files (scripts/, .github/) stay.
rm -rf "${ROOT_DIR}/src" "${ROOT_DIR}/examples"
cp -a "${OUTPUT_DIR}/src" "${ROOT_DIR}/src"
[ -d "${OUTPUT_DIR}/examples" ] && cp -a "${OUTPUT_DIR}/examples" "${ROOT_DIR}/examples"
cp -a "${OUTPUT_DIR}/library.properties" "${ROOT_DIR}/library.properties"
echo "Generated from tflite-micro ${UPSTREAM_SHA}"
