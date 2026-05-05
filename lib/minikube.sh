check_minikube() {
  echo "Checking minikube..."

  case "$OS" in
    linux|darwin)
      if ! command -v minikube &>/dev/null; then
        confirm "minikube is not installed. Download and install it now?"
        curl -fsSL "https://storage.googleapis.com/minikube/releases/latest/minikube-${OS}-${ARCH}" -o /tmp/minikube
        sudo install /tmp/minikube /usr/local/bin/minikube
        rm /tmp/minikube
      fi
      ;;
    windows)
      if ! command -v minikube &>/dev/null; then
        echo "ERROR: minikube is not installed. Download from https://minikube.sigs.k8s.io/docs/start/ and re-run." >&2
        exit 1
      fi
      ;;
  esac

  MINIKUBE_STATUS="$(minikube status --format='{{.Host}}' 2>/dev/null || echo 'Stopped')"
  if [[ "$MINIKUBE_STATUS" != "Running" ]]; then
    confirm "minikube is not running. Start it now?"
    minikube start
  fi

  if ! minikube status --format='{{.Host}}' 2>/dev/null | grep -q "Running"; then
    echo "ERROR: minikube failed to start." >&2
    exit 1
  fi

  echo "minikube is running."
}