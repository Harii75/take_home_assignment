check_docker() {
  echo "Checking Docker..."

  case "$OS" in
    linux)
      if ! command -v docker &>/dev/null; then
        confirm "Docker is not installed. This will run the official install script (https://get.docker.com)."
        curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
        sh /tmp/get-docker.sh
        rm /tmp/get-docker.sh
        if ! groups "$USER" | grep -q docker; then
          confirm "Add '$USER' to the docker group to run Docker without sudo? (requires logout/login to take effect)"
          sudo usermod -aG docker "$USER"
          echo "Note: log out and back in for the group change to take effect, or run: newgrp docker"
        fi
      fi
      if ! docker info &>/dev/null 2>&1; then
        confirm "Docker is installed but not running. Start it via systemctl?"
        sudo systemctl start docker
        sudo systemctl enable docker
      fi
      ;;
    darwin|windows)
      if ! command -v docker &>/dev/null; then
        echo "ERROR: Docker is not installed. Download Docker Desktop from https://www.docker.com/products/docker-desktop/ and re-run." >&2
        exit 1
      fi
      if ! docker info &>/dev/null 2>&1; then
        echo "ERROR: Docker is not running. Start Docker Desktop and re-run." >&2
        exit 1
      fi
      ;;
  esac

  echo "Docker is running."
}