#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/lib/docker.sh"
source "${SCRIPT_DIR}/lib/minikube.sh"
source "${SCRIPT_DIR}/lib/kubectl.sh"

confirm() {
  echo ""
  echo "$1"
  read -r -p "  Proceed? [y/N] " answer
  [[ "$answer" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
}

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "$ARCH" in
  x86_64)        ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
esac

case "$OS" in
  linux|darwin) ;;
  mingw*|msys*|cygwin*) OS="windows" ;;
  *)
    echo "ERROR: Unrecognised OS: $OS" >&2
    exit 1
    ;;
esac

echo "Detected: ${OS}/${ARCH}"

BINARY="bin/rest_1.0_${OS}_${ARCH}"

case "${OS}/${ARCH}" in
  linux/amd64|linux/arm64|darwin/amd64|darwin/arm64|windows/arm64)
    if [[ ! -f "$BINARY" ]]; then
      echo "ERROR: Binary not found: ${BINARY} — make sure bin/ is present." >&2
      exit 1
    fi
    ;;
  windows/amd64)
    echo "Incompatible: no binary for windows/amd64. Available Windows build: windows/arm64 only."
    exit 1
    ;;
  *)
    echo "Incompatible: no binary for ${OS}/${ARCH}."
    echo "Supported: linux/amd64, linux/arm64, darwin/amd64, darwin/arm64, windows/arm64"
    exit 1
    ;;
esac

check_docker
check_minikube
check_kubectl
