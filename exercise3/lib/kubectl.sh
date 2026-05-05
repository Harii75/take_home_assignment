check_kubectl() {
  echo "Checking kubectl..."

  case "$OS" in
    linux|darwin)
      if ! command -v kubectl &>/dev/null; then
        confirm "kubectl is not installed. Download and install it now?"
        KUBECTL_VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
        curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/${OS}/${ARCH}/kubectl" -o /tmp/kubectl
        sudo install /tmp/kubectl /usr/local/bin/kubectl
        rm /tmp/kubectl
      fi
      ;;
    windows)
      if ! command -v kubectl &>/dev/null; then
        echo "ERROR: kubectl is not installed. Download from https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/ and re-run." >&2
        exit 1
      fi
      ;;
  esac

  echo "kubectl is ready."
}
