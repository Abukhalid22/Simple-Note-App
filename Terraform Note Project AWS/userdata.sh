#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Log all output to file
exec >> /var/log/userdata.log 2>&1

echo "Starting initialization script..."

# Update package lists and install any available updates
sudo apt update -y
sudo apt upgrade -y

# Install essential utilities
sudo apt install -y curl wget git python3 python3-pip nodejs npm

# Install Docker
sudo apt install -y docker.io
sudo systemctl enable --now docker

# Add current user to the docker group
sudo usermod -aG docker ubuntu

sleep 15

# Install Gunicorn
sudo apt install -y gunicorn

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install

# Install kubectl
sudo apt update
sudo apt install curl -y
sudo curl -LO "https://dl.k8s.io/release/v1.28.4/bin/linux/amd64/kubectl"
sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

# Install Minikube
curl -LO "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"
sudo chmod +x minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/local/bin/minikube

# Start Minikube cluster with Docker driver
# Run Minikube as the non-root user
sudo -u ubuntu minikube start --driver=docker

# Wait for Minikube to start
echo "Waiting for Minikube to start..."
sleep 30

# Enable Minikube addons
sudo -u ubuntu minikube addons enable ingress

# Install Argo CD with Kubectl
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.4.7/manifests/install.yaml
sudo apt install jq -y

# Installing Helm
sudo snap install helm --classic

# Adding Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace

# Install Grafana
helm install grafana grafana/grafana --namespace monitoring --create-namespace

# Install ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx

# Clone your project repository (Optional)
----

# Print instructions for accessing your application
echo "Your application has been deployed successfully."
echo "Initialization script completed successfully."

