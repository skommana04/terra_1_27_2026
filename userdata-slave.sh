#!/bin/bash
set -euo pipefail
# Update & install Java
sudo apt update

sudo growpart /dev/nvme0n1 4
sudo lvextend -L +10G /dev/mapper/RootVG-varVol
sudo lvextend -L +10G /dev/mapper/RootVG-rootVol
sudo lvextend -l +100%FREE /dev/mapper/RootVG-homeVol

sudo xfs_growfs /
sudo xfs_growfs /var
sudo xfs_growfs /home

sudo apt install -y openjdk-21-jre
# Optional: create Jenkins user
#sudo useradd -m -s /bin/bash jenkins