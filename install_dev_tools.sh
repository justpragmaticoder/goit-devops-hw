#!/bin/bash

set -e

# Detect if we’re running as root; if not, prefix commands with sudo
if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

echo "----- Checking and installing Docker -----"
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    $SUDO apt-get update
    $SUDO apt-get install -y ca-certificates curl gnupg lsb-release

    # Add Docker’s official GPG key and repository
    $SUDO install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
      | $SUDO gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    $SUDO chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) \
      signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" \
      | $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null

    $SUDO apt-get update
    $SUDO apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo "Docker has been installed."
else
    echo "Docker is already installed."
fi

echo "----- Checking and installing Docker Compose (standalone) -----"
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose not found. Installing Docker Compose..."
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest \
      | grep '"tag_name":' | cut -d '"' -f 4)
    curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
      -o docker-compose
    $SUDO mv docker-compose /usr/local/bin/docker-compose
    $SUDO chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose has been installed."
else
    echo "Docker Compose is already installed."
fi

echo "----- Checking and installing Python 3.9+ -----"
PYTHON_MIN_VERSION="3.9"
if ! command -v python3 &> /dev/null; then
    PYTHON_CUR_VERSION="0"
else
    PYTHON_CUR_VERSION=$(python3 -V 2>&1 | awk '{print $2}')
fi

# Compare versions using sort -V
if [ "$(printf '%s\n' "$PYTHON_MIN_VERSION" "$PYTHON_CUR_VERSION" | sort -V | head -n1)" != "$PYTHON_MIN_VERSION" ]; then
    echo "Python $PYTHON_MIN_VERSION+ not found or version is older. Installing Python..."
    $SUDO apt-get update
    $SUDO apt-get install -y python3 python3-pip
    echo "Python $PYTHON_MIN_VERSION+ has been installed."
else
    echo "Python is already installed: $PYTHON_CUR_VERSION"
fi

echo "----- Checking and installing pip3 -----"
if ! command -v pip3 &> /dev/null; then
    echo "pip3 not found. Installing python3-pip..."
    $SUDO apt-get update
    $SUDO apt-get install -y python3-pip
    echo "pip3 has been installed."
else
    echo "pip3 is already installed: $(pip3 --version)"
fi

echo "----- Checking and installing Django -----"
if ! python3 -m django --version &> /dev/null; then
    echo "Django not found. Installing Django via pip..."
    pip3 install --user Django
    echo "Django has been installed."
else
    echo "Django is already installed: $(python3 -m django --version)"
fi

echo "----- All tools are installed and up to date! -----"