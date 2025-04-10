# Variables
REPO_NAME := simple_store
IMAGE_NAME := app
GHCR_USER := poloturiot
IMAGE_TAG := latest
GHCR_IMAGE_PATH := ghcr.io/$(GHCR_USER)/$(REPO_NAME)/$(IMAGE_NAME):$(IMAGE_TAG)
LOCAL_IMAGE_PATH := $(IMAGE_NAME):$(IMAGE_TAG)
K8S_DIR := . # Directory containing Kubernetes YAML files, assumes current directory
K8S_DEPLOYMENT_NAME := frontend-deployment # Name of your deployment resource
GATEWAY_API_CRD_URL := https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml

# Default target (optional, often set to build)
.PHONY: all
all: build

# Build the Docker image locally
.PHONY: build
build:
	@echo "Building Docker image $(LOCAL_IMAGE_PATH)..."
	docker build -t $(LOCAL_IMAGE_PATH) .

# Log in to GitHub Container Registry (requires interactive PAT input)
.PHONY: login
login:
	@echo "Logging into GHCR as $(GHCR_USER)..."
	docker login ghcr.io -u $(GHCR_USER)

# Tag the local image and push it to GHCR
# Assumes you are already logged in (use 'make login' first if needed)
.PHONY: push
push: build
	@echo "Tagging image for GHCR as $(GHCR_IMAGE_PATH)..."
	docker tag $(LOCAL_IMAGE_PATH) $(GHCR_IMAGE_PATH)
	@echo "Pushing image to $(GHCR_IMAGE_PATH)..."
	docker push $(GHCR_IMAGE_PATH)

# Clean up local images (optional)
.PHONY: clean
clean:
	@echo "Removing local Docker images..."
	docker rmi $(LOCAL_IMAGE_PATH) || true
	docker rmi $(GHCR_IMAGE_PATH) || true

# Apply Kubernetes resources
.PHONY: apply-k8s
apply-k8s:
	@echo "Applying Kubernetes resources from $(K8S_DIR)..."
	kubectl apply -f $(K8S_DIR)
	@echo "Forcing rollout restart for deployment $(K8S_DEPLOYMENT_NAME)..."
	kubectl rollout restart deployment $(K8S_DEPLOYMENT_NAME)

# Install Kubernetes Gateway API CRDs
.PHONY: install-gateway-api-crds
install-gateway-api-crds:
	@echo "Installing Kubernetes Gateway API CRDs..."
	kubectl apply -f $(GATEWAY_API_CRD_URL)

# Install Kong Ingress Controller using Helm (depends on Gateway API CRDs)
.PHONY: install-kong
install-kong: install-gateway-api-crds
	@echo "Adding Kong Helm repository..."
	helm repo add kong https://charts.konghq.com
	@echo "Updating Helm repositories..."
	helm repo update
	@echo "Installing Kong Ingress Controller into namespace '$(KONG_NAMESPACE)'..."
	helm install $(KONG_RELEASE_NAME) kong/kong --namespace $(KONG_NAMESPACE) --create-namespace --generate-name
