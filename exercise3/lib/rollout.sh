deploy() {
  echo "Applying manifests..."
  kubectl apply -f ./k8s/namespace.yaml
  kubectl apply -f ./k8s/

  echo "Waiting for rollout..."
  kubectl rollout status deployment/rest-service \
    --namespace=hello-world \
    --timeout=90s

  MINIKUBE_IP="$(minikube ip)"
  NODE_PORT="$(kubectl get svc rest-service --namespace=hello-world -o jsonpath='{.spec.ports[0].nodePort}')"
  SERVICE_URL="http://${MINIKUBE_IP}:${NODE_PORT}"

  echo "Waiting for service..."
  for i in $(seq 1 12); do
    RESPONSE="$(curl -sf "${SERVICE_URL}/hello-world" 2>/dev/null || true)"
    if [[ "$RESPONSE" == *"Hello"* ]]; then
      echo ""
      echo "Service is up!"
      echo "  GET ${SERVICE_URL}/hello-world -> ${RESPONSE}"
      break
    fi
    [[ $i -eq 12 ]] && { echo "ERROR: Timed out. Try: curl ${SERVICE_URL}/hello-world" >&2; exit 1; }
    echo "  attempt ${i}/12..."
    sleep 5
  done
  
  echo "Starting port-forward on localhost:8080..."
  kubectl port-forward svc/rest-service --namespace=hello-world 8080:80 &>/dev/null &
  echo "Open in browser: http://localhost:8080/hello-world"
}