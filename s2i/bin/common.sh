#!/bin/bash
#
# Common functions and environment variables for S2i and Buildpacks.
#

function print_phase() {
    echo "---> Phase: ${*}..."
}

function fail() {
    echo "ERROR: ${*}" 2>&1
}

#
# Required Environment Variables
#

readonly S2I_SRC_DIR=${S2I_SRC_DIR:-}
[[ -z "${S2I_SRC_DIR}" ]] &&
    fail "S2I source directory (S2I_SRC_DIR) is not defined!"

# informs the target fully qualified container image name
readonly S2I_IMAGE_TAG=${S2I_IMAGE_TAG:-}
[[ -z "${S2I_IMAGE_TAG}" ]] &&
    fail "S2I target image-tag (S2I_IMAGE_TAG) is not defined!"

readonly S2I_ARTIFACTS_DIR=${S2I_ARTIFACTS_DIR:-}
[[ -z "${S2I_ARTIFACTS_DIR}" ]] &&
    fail "S2I artifact directory (S2I_ARTIFACTS_DIR) is not defined!"

readonly CNB_BASE_DIR=${CNB_BASE_DIR:-}
[[ -z "${CNB_BASE_DIR}" ]] &&
    fail "Buidlpacks base directory (CNB_BASE_DIR) is not defined!"

#
# Buildpacks CNB Settings
#

export CNB_APP_DIR="${HOME}"

export CNB_CACHE_DIR="${CNB_BASE_DIR}/cache"
export CNB_LAYERS_DIR="${CNB_BASE_DIR}/layers"

readonly METADATA_DIR="${CNB_BASE_DIR}/metadata"

export CNB_ANALYZED_PATH="${CNB_BASE_DIR}/analyzed.toml"
export CNB_REPORT_PATH="${METADATA_DIR}"
