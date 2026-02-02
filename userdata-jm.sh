#!/bin/bash
set -euo pipefail

# -----------------------------
# Optional: Disk resize (uncomment if your AMI uses LVM)
# -----------------------------
# growpart /dev/nvme0n1 4
# lvextend -L +10G /dev/mapper/RootVG-varVol
# lvextend -L +10G /dev/mapper/RootVG-rootVol
# lvextend -l +100%FREE /dev/mapper/RootVG-homeVol
# xfs_growfs /
# xfs_growfs /var
# xfs_growfs /home

# -----------------------------
# Update system
# -----------------------------
dnf update -y

# -----------------------------
# Install Java 11
# -----------------------------
dnf install java-17-openjdk -y

# -----------------------------
# Download Jenkins WAR (for RHEL 9 / EL9)
# -----------------------------
mkdir -p /opt/jenkins
#wget https://get.jenkins.io/war-stable/latest/jenkins.war -O /opt/jenkins/jenkins.war
curl -L -o /opt/jenkins/jenkins.war https://get.jenkins.io/war-stable/latest/jenkins.war --tlsv1.2

# -----------------------------
# Create a systemd service for Jenkins (optional, makes it auto-start)
# -----------------------------
cat <<EOF > /etc/systemd/system/jenkins.service
[Unit]
Description=Jenkins Daemon
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/java -jar /opt/jenkins/jenkins.war --httpPort=8080
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# -----------------------------
# Enable & start Jenkins
# -----------------------------
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

# -----------------------------
# Finished
# -----------------------------
echo "Jenkins setup complete. Access on port 8080."
