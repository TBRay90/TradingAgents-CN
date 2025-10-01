#!/usr/bin/env bash
set -euo pipefail

# Docker installation script for Ubuntu 24.04.3 LTS

info() {
  printf '\033[1;34m[INFO]\033[0m %s\n' "$1"
}

error() {
  printf '\033[1;31m[ERROR]\033[0m %s\n' "$1" >&2
}

require_root() {
  if [[ "$EUID" -ne 0 ]]; then
    error "This script must be run as root. Try: sudo $0"
    exit 1
  fi
}

install_dependencies() {
  info "Updating APT package index"
  apt update

  info "Installing prerequisite packages"
  apt install -y ca-certificates curl gnupg lsb-release
}

setup_repository() {
  info "Setting up Docker's official GPG key"
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  info "Adding Docker repository"
  local codename
  codename=$(lsb_release -cs)
  printf "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu %s stable\n" "$codename" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null
}

install_docker() {
  info "Installing Docker Engine and related packages"
  apt update
  apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

post_install() {
  if ! getent group docker > /dev/null; then
    info "Creating docker group"
    groupadd docker
  fi

  if id -nG "$SUDO_USER" 2>/dev/null | grep -qw docker; then
    info "User $SUDO_USER is already in docker group"
  else
    info "Adding $SUDO_USER to docker group"
    usermod -aG docker "$SUDO_USER"
    info "Run 'newgrp docker' or log out/in for group changes to take effect"
  fi
}

run_hello_world() {
  info "Running hello-world test container"
  sudo -u "$SUDO_USER" docker run --rm hello-world
}

main() {
  require_root
  if [[ -z "${SUDO_USER:-}" ]]; then
    error "Script must be run via sudo to update user groups."
    exit 1
  fi

  install_dependencies
  setup_repository
  install_docker
  post_install

  info "Docker installation completed successfully."
  info "Log out and log back in, or run 'newgrp docker' to apply group changes."
  info "You can verify Docker with: docker run hello-world"
}

main "$@"
