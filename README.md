# GitHub Actions

This repository contains reusable GitHub Actions for DataGenie projects. These actions are designed to standardize common CI/CD workflows across repositories.

## Available Actions

### 1. Setup Base (`setup-base.yml`)

A composite action that sets up the base Python environment for workflows.

**Inputs:**
- `python-version`: Python version to use (default: "3.12")
- `poetry-no-root`: Whether to install Poetry without root (default: true)
- `poetry-groups`: Comma-separated list of Poetry groups to install (default: "dev")
- `private-repo-access`: Whether to set up SSH for accessing private repositories (default: true)
- `repo-ssh-key`: SSH private key for accessing private repos
- `repo-host-config`: SSH host config for accessing private repos

**Features:**
- Sets up Python environment
- Installs Poetry
- Configures caching for Poetry virtualenv
- Installs system dependencies (gcc, g++)
- Sets up SSH for private repository access if needed
- Installs Python dependencies using Poetry

---

### 2. Unit Test (`unit-test.yml`)

Runs unit tests and code quality checks for Python projects.

**Inputs:**
No additional inputs required. Only inherits inputs from `setup-base`

**Features:**
- Inherits all functionality from `setup-base`
- Runs Ruff linter
- Performs Ruff format checking
- Executes unit tests with pytest
- Generates coverage reports
- Uploads test results and coverage reports

---

### 3. Build Wheel and Release (`build-wheel-and-release.yml`)

Builds obfuscated Python wheels and releases them to the DG Artifacts repository.

**Inputs:**
- `module`: Module to build wheel for (required) eg: anomaly_detection, metrics_ingestor
- `target_folders`: Comma-separated list of target folders in dg-artifacts (required) eg: AD, TS, REPORTS etc
- `python-version`: Python version to use (default: "3.12")
- `poetry-no-root`: Whether to install Poetry without root (default: true)
- `poetry-groups`: Comma-separated list of Poetry groups to install (default: "dev, build")
- `private-repo-access`: Whether to access private repositories (default: true)
- `repo-ssh-key`: SSH private key for accessing private repos
- `repo-host-config`: SSH host config for accessing private repos
- `dg-artifacts-pat`: DG Artifacts PAT to upload to dg-artifacts repo

**Features:**
- Inherits all functionality from `setup-base`
- Obfuscates the specified module
- Builds a wheel package
- Packages the wheel with job_runner.py
- Releases to the DG Artifacts repository
- Supports multiple target folders

---

### 4. Setup Docker Base (`setup-docker-base.yml`)

Sets up and builds Docker images with optional security scanning.

**Inputs:**
- `image-name`: Name of the docker image (required)
- `tag`: Tag to use for the docker image (default: 'from-pyproject')
- `private-repo-access`: Whether to access private repositories (default: true)
- `repo-ssh-key`: SSH private key for accessing private repos
- `script-to-add-private-pkgs`: Script to add private packages
- `run-docker-scout`: Whether to run docker scout (default: true)
- `build-args`: Optional build arguments to pass to Docker build
- `github-token`: GitHub token to use for accessing private repos
- `docker-user`: Docker username to use for accessing private repos
- `docker-password`: Docker password to use for accessing private repos

**Features:**
- Automatically extracts version from pyproject.toml if tag is 'from-pyproject'
- Logs into GitHub Container Registry
- Sets up SSH for private repository access if needed
- Configures Docker Buildx for building
- Builds and pushes Docker images to GitHub Container Registry
- Performs security scanning using Docker Scout
- Generates SBOM (Software Bill of Materials)
- Posts security scan results as a comment on the PR

## Usage Example

### Example with Unit test and Docker
> This example shows how to use unit test and docker actions together for a service repo like `ad-service`

```yaml
name: AD as a Service CI/CD Pipeline

on:
  push:
    tags:
      - '*'
    branches:
      - 'main'
  pull_request:
    branches:
      - '*'
  workflow_dispatch:

jobs:
  tests:
    runs-on: ubuntu-latest
    steps:
      - name: Run Unit Tests
        uses: datagenie-ai/.github/.github/actions/unit-test@main
        with:
          private-repo-access: true
          repo-ssh-key: ${{ secrets.REPO_SSH_KEY }}
          repo-host-config: ${{ secrets.REPO_HOST_CONFIG }}

  docker:
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && (github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/'))
    needs: [tests]
    steps:
      - name: Create Docker Image
        uses: datagenie-ai/.github/.github/actions/setup-docker-base@main
        with:
          image-name: ad-service
          private-repo-access: true
          build-args: |
            GITHUB_TOKEN=${{ secrets.DG_ARTIFACTS_PAT }}
            ARTIFACT_VERSION=14.11.0
          repo-ssh-key: ${{ secrets.REPO_SSH_KEY }}
          script-to-add-private-pkgs: ${{ secrets.SCRIPT_TO_ADD_PRIVATE_PKGS }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
          docker-user: ${{ secrets.DOCKER_USERNAME }}
          docker-password: ${{ secrets.DOCKER_PASSWORD }}

```

### Example with Unit test and Wheel Release
> This example shows how to use unit test and wheel release actions together for a job repo like `metrics_ingestor`

```yaml
name: Metrics Ingestor CI Pipeline

on:
  push:
    tags:
      - '*'
    branches:
      - 'main'
  pull_request:
    branches:
      - '*'
  workflow_dispatch:

jobs:
  tests:
    runs-on: ubuntu-latest
    steps:
      - name: Run Unit Tests
        uses: datagenie-ai/.github/.github/actions/unit-test@main
        with:
          private-repo-access: true
          repo-ssh-key: ${{ secrets.REPO_SSH_KEY }}
          repo-host-config: ${{ secrets.REPO_HOST_CONFIG }}

  release:
    needs: [tests]
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && (github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/'))
    steps:
      - name: Create Docker Image
        uses: datagenie-ai/.github/.github/actions/build-wheel-and-release@main
        with:
          module: metrics_ingestor
          target_folders: TS,REPORTS,PROFILER
          dg-artifacts-pat: ${{ secrets.DG_ARTIFACTS_PAT }}
          repo-ssh-key: ${{ secrets.REPO_SSH_KEY }}
          repo-host-config: ${{ secrets.REPO_HOST_CONFIG }}

```


## Security

- All actions support private repository access via SSH
- Docker images are scanned for vulnerabilities using Docker Scout
- Sensitive operations use GitHub Secrets for authentication
- SSH keys are properly secured with appropriate permissions

## Requirements

- GitHub Actions
- Poetry (for Python projects)
- Docker (for Docker-related actions)
- Appropriate GitHub Secrets configured for private repository access
