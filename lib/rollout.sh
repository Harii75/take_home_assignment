deploy() {
  echo "Applying manifests..."
  kubectl apply -f ./k8s/namespace.yaml
  kubectl apply -f ./k8s/
  
  echo "Waiting for rollout..."
  kubectl rollout status deployment/rest-service \
    --namespace=hello-world \
    --timeout=90s

  if ! pgrep -f "minikube tunnel" &>/dev/null; then
    echo "Starting minikube tunnel (may prompt for sudo)..."
    nohup minikube tunnel --profile="${MINIKUBE_PROFILE}" >/tmp/minikube-tunnel.log 2>&1 &
    sleep 3
  fi

  echo "Waiting for service..."
  for i in $(seq 1 12); do
    RESPONSE="$(curl -sf "http://localhost:${NODEPORT}/hello-world" 2>/dev/null || true)"
    if [[ "$RESPONSE" == *"Hello"* ]]; then
      echo "Service is up: GET http://localhost:${NODEPORT}/hello-world -> ${RESPONSE}"
      break
    fi
    [[ $i -eq 12 ]] && { echo "ERROR: Timed out. Try: curl http://localhost:${NODEPORT}/hello-world" >&2; exit 1; }
    echo "  attempt ${i}/12..."
    sleep 5
  done
}
