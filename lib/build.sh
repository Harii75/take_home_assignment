build() {
  echo "Forwarding minikube registry to localhost:${REGISTRY_PORT}..."
  pkill -f "kubectl.*port-forward.*${REGISTRY_PORT}" 2>/dev/null || true
  sleep 1
  kubectl port-forward --namespace kube-system service/registry "${REGISTRY_PORT}:80" &>/dev/null &
  FORWARD_PID=$!
  sleep 2

  echo "Building image..."
  docker build --tag "${IMAGE}" .

  echo "Pushing image to local registry..."
  docker push "${IMAGE}"

  kill "${FORWARD_PID}" 2>/dev/null || true
}
