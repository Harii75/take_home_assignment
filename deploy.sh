#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/lib/build.sh"
source "${SCRIPT_DIR}/lib/rollout.sh"

IMAGE="localhost:5000/rest-service:1.0"
REGISTRY_PORT="5000"
MINIKUBE_PROFILE="minikube"
NODEPORT="30080"
NAMESPACE="hello-world"

echo "Running pre-flight checks..."
bash "${SCRIPT_DIR}/install.sh"

[[ -f "Dockerfile" ]] || { echo "ERROR: Run this script from the project root." >&2; exit 1; }

case "$(uname -m)" in
  x86_64)        TARGETARCH="amd64" ;;
  aarch64|arm64) TARGETARCH="arm64" ;;
  *) echo "ERROR: Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

echo "Architecture: ${TARGETARCH}"

echo "Starting minikube..."
MINIKUBE_STATUS="$(minikube status --profile="${MINIKUBE_PROFILE}" --format='{{.Host}}' 2>/dev/null || echo 'Stopped')"

if [[ "$MINIKUBE_STATUS" != "Running" ]]; then
  minikube start \
    --profile="${MINIKUBE_PROFILE}" \
    --insecure-registry="localhost:${REGISTRY_PORT}"
fi

minikube addons enable registry --profile="${MINIKUBE_PROFILE}" 2>/dev/null || true
kubectl config use-context "${MINIKUBE_PROFILE}" >/dev/null

build
deploy
