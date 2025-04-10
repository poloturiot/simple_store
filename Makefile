# Variables
REPO_NAME := simple_store
IMAGE_NAME := app
GHCR_USER := poloturiot
IMAGE_TAG := latest
GHCR_IMAGE_PATH := ghcr.io/$(GHCR_USER)/$(REPO_NAME)/$(IMAGE_NAME):$(IMAGE_TAG)
LOCAL_IMAGE_PATH := $(IMAGE_NAME):$(IMAGE_TAG)
K8S_DIR := . # Directory containing Kubernetes YAML files, assumes current directory
K8S_DEPLOYMENT_NAME := frontend-deployment # Name of your deployment resource

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
