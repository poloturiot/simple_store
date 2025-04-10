# Simple Web Store

A basic static web store frontend served via Nginx, containerized with Docker, and deployable to Kubernetes.

## Project Structure

-   `index.html`: Main HTML file for the store.
-   `style.css`: CSS styling for the store.
-   `script.js`: JavaScript for potential frontend logic (currently minimal).
-   `Dockerfile`: Defines how to build the Docker image using Nginx.
-   `Makefile`: Provides convenience commands for building, pushing, and deploying.
-   `frontend-deployment.yaml`: Kubernetes Deployment definition.
-   `ghcr-creds.yaml`: (Template/Example) Kubernetes Secret for GHCR credentials. *Note: Contains sensitive data placeholder, should be generated securely.*
-   *(Optional)* `frontend-service.yaml`: Kubernetes Service definition (if you create one to expose the deployment).

## Prerequisites

-   [Docker](https://docs.docker.com/get-docker/)
-   [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (configured to connect to your Kubernetes cluster)
-   [Make](https://www.gnu.org/software/make/) (usually pre-installed on Linux/macOS, available for Windows)
-   A [GitHub Personal Access Token (PAT)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) with `read:packages` and `write:packages` scopes for interacting with the GitHub Container Registry (GHCR).

## Setup

1.  **Clone the repository** (if applicable).
2.  **Configure Makefile:** Edit the `Makefile` and replace `YOUR_GITHUB_USERNAME` in the `GHCR_USER` variable with your actual GitHub username or organization name.
3.  **Create GHCR Secret:**
    *   **Option A (Declarative):** Follow the instructions in the `ghcr-creds.yaml` comments to generate the base64 encoded value using `kubectl create secret --dry-run` and paste it into the file.
    *   **Option B (Imperative):** Run the `kubectl create secret docker-registry` command directly (see [Kubernetes Docs](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) or previous instructions). Make sure to replace placeholders with your GitHub username and PAT.

## Usage (Makefile Commands)

1.  **Build the Docker Image:**
    ```bash
    make build
    ```
    This builds the image locally using the `Dockerfile` and tags it as `app:latest`.

2.  **Log in to GHCR:**
    ```bash
    make login
    ```
    You will be prompted for your password; paste your GitHub PAT here. This is required before pushing.

3.  **Push the Image to GHCR:**
    ```bash
    make push
    ```
    This tags the locally built image for GHCR (`ghcr.io/YOUR_GITHUB_USERNAME/simple_store/app:latest`) and pushes it. Requires prior login (`make login`).

4.  **Deploy to Kubernetes:**
    ```bash
    make apply-k8s # Applies K8s resources (Deployment, Secret, etc.)
    ```
    This applies the Kubernetes YAML files (like `frontend-deployment.yaml`, `ghcr-creds.yaml`) to your cluster. `deploy-k8s` also restarts the deployment pods to ensure they pull the latest image if using the `:latest` tag.

## Cleanup

-   **Remove Kubernetes Resources:**
    ```bash
    kubectl delete -f . # Deletes resources defined in the YAML files
    # or delete specific resources
    kubectl delete deployment frontend-deployment
    kubectl delete secret ghcr-creds
    ```
-   **Remove Local Docker Images:**
    ```bash
    make clean
    ``` 