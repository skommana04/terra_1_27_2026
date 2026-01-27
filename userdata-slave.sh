#!/bin/bash
set -euo pipefail
# Update & install Java
sudo apt update
sudo apt install -y openjdk-21-jre
# Optional: create Jenkins user
sudo useradd -m -s /bin/bash jenkins