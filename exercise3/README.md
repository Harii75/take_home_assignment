# Exercise 3: Kubernetes Deployment

Deploys the `rest-service` REST application to a local minikube cluster with a single command.

The service exposes a single endpoint:

```
GET /hello-world
```

```json
{"message": "Hello World!"}
```

---

## Prerequisites

| Tool | Purpose | Auto-installed |
|------|---------|---------------|
| Docker | Build and push the container image | Linux only |
| minikube | Local Kubernetes cluster | Linux, macOS |
| kubectl | Manage the cluster | Linux, macOS |

On Windows, all tools must be installed manually. The script will print the relevant download links and exit.

> **Note:** Only `windows/arm64` is supported on Windows. Standard Intel/AMD Windows machines are not compatible with the provided binaries.

---

## Usage

```bash
./deploy.sh
```

The script handles the full flow:

1. Detects OS and architecture
2. Validates the correct binary exists in `bin/`
3. Installs Docker, minikube, and kubectl if missing (Linux/macOS)
4. Starts minikube if not running
5. Enables the minikube internal registry addon
6. Builds the Docker image using the binary matching your architecture
7. Pushes the image to the minikube internal registry (no external registry needed)
8. Creates the `hello-world` namespace and applies all manifests
9. Waits for the pod to become ready
10. Smoke tests the endpoint
11. Starts a port-forward so the service is reachable from your browser

Once complete:

```
http://localhost:8080/hello-world

---

## Project structure

```
exercise3/
├── deploy.sh            # entry point, run this
├── install.sh           # preflight: OS detection, binary check, tool install
├── Dockerfile           # builds the container image using alpine:3.23
├── .dockerignore
├── k8s/
│   ├── namespace.yaml   # creates the hello-world namespace
│   ├── deployment.yaml  # 1 replica, resource limits, health probes, non-root
│   └── service.yaml     # NodePort on 30080
├── lib/
│   ├── build.sh         # forwards registry, builds and pushes image
│   ├── rollout.sh       # applies manifests, waits for rollout, port-forwards
│   ├── docker.sh        # check_docker()
│   ├── minikube.sh      # check_minikube()
│   └── kubectl.sh       # check_kubectl()
└── bin/
    ├── rest_1.0_linux_amd64
    ├── rest_1.0_linux_arm64
    ├── rest_1.0_darwin_amd64
    ├── rest_1.0_darwin_arm64
    └── rest_1.0_windows_arm64
```
