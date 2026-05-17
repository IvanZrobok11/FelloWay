#!/usr/bin/env bash
# Join domain OpenAPI YAML → openapi.json, then generate Dart client (dart-dio). npm CLIs only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTRACTS_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${CONTRACTS_ROOT}/../.." && pwd)"
OUTPUT_JSON="${CONTRACTS_ROOT}/openapi.json"
GENERATED_DIR="${REPO_ROOT}/frontend/lib/generated/felloway_api"

run_redocly() {
  if command -v redocly >/dev/null 2>&1; then
    redocly "$@"
  else
    npx --yes @redocly/cli "$@"
  fi
}

run_openapi_generator() {
  if command -v openapi-generator-cli >/dev/null 2>&1; then
    openapi-generator-cli "$@"
  else
    npx --yes @openapitools/openapi-generator-cli "$@"
  fi
}

if ! command -v node >/dev/null 2>&1; then
  echo "ERROR: node is required. Install Node.js 18+." >&2
  exit 1
fi

if ! command -v java >/dev/null 2>&1; then
  echo "ERROR: java is required for openapi-generator-cli (JDK 11+)." >&2
  exit 1
fi

if ! command -v dart >/dev/null 2>&1; then
  echo "ERROR: dart is required for build_runner in the generated package." >&2
  exit 1
fi

if ! command -v openapi-generator-cli >/dev/null 2>&1; then
  echo "NOTE: openapi-generator-cli not on PATH. Using npx @openapitools/openapi-generator-cli."
  echo "      Install globally: npm install -g @openapitools/openapi-generator-cli"
fi

for domain in common auth users events; do
  if [[ ! -f "${CONTRACTS_ROOT}/${domain}/openapi.yaml" ]]; then
    echo "ERROR: Missing ${CONTRACTS_ROOT}/${domain}/openapi.yaml" >&2
    exit 1
  fi
done

echo "==> Joining OpenAPI domain contracts (Redocly)..."
cd "${CONTRACTS_ROOT}"
run_redocly join \
  common/openapi.yaml \
  auth/openapi.yaml \
  users/openapi.yaml \
  events/openapi.yaml \
  -o "${OUTPUT_JSON}" \
  --without-x-tag-groups

echo "==> Generating Dart client (dart-dio)..."
run_openapi_generator generate \
  -i "${OUTPUT_JSON}" \
  -g dart-dio \
  -o "${GENERATED_DIR}" \
  -c openapi-generator-config.yaml \
  --openapi-normalizer REF_AS_PARENT_IN_ALLOF=true \
  --skip-validate-spec

echo "==> Running build_runner (built_value serializers)..."
(cd "${GENERATED_DIR}" && dart run build_runner build)

echo "==> Done."
echo "    Merged spec: ${OUTPUT_JSON}"
echo "    Dart client: ${GENERATED_DIR}"
echo "    Next: cd frontend && flutter pub get && flutter analyze"
