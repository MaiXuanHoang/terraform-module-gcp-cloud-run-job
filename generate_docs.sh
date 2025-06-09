#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

echo "Generate terraform docs"
terraform-docs -c ${SCRIPT_DIR}/.terraform-docs.yml ${SCRIPT_DIR}
terraform-docs -c ${SCRIPT_DIR}/.terraform-docs.yml ${SCRIPT_DIR}/gcs_bucket
terraform-docs -c ${SCRIPT_DIR}/.terraform-docs.yml ${SCRIPT_DIR}/secret
