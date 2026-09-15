# CI/CD for Web Application on EC2 with Docker Compose

## Overview

The goal of this task is to implement a **CI/CD pipeline** for a web application deployed on **AWS EC2 instances** using **Docker Compose**.

The pipeline should:

- Automatically build new container images based on **GitHub tag releases**
- Update the Docker Compose configuration with the new image tag
- Deploy the new version on the EC2 instance using **only shell commands** (no pre-made GitHub Actions for Docker or Compose)

> Focus is on automation, shell scripting, version management, and deployment.

---

## Technology Stack 🛠️

- **GitHub Actions** – CI/CD pipeline
- **EC2 Instances** – Deployment targets
- **Docker & Docker Compose** – Application containers
- **Shell scripting** – To perform all CI/CD steps

Optional: Web application can be **generated via AI** (Node.js, Flask, or simple static site).

---

## Functional Requirements 🔧

### CI (Continuous Integration)

1. Trigger pipeline on **GitHub tag creation**
2. Build a new **Docker image** using the source code
3. Tag the image with the **GitHub release/tag version**
4. Push the Docker image to a **container registry** (Docker Hub, ECR, or private registry)

---

### CD (Continuous Deployment)

1. SSH into the EC2 instance(s)
2. Pull the updated Docker Compose file or update **image tag** in existing file
3. Run the updated Docker Compose stack with:

```bash
docker-compose pull
docker-compose up -d
```

1. Verify the application is running correctly

> Important: All steps must use shell commands only, no pre-built GitHub Actions for Docker Compose deployment.

---

## Pipeline Steps 📝

1. **CI Stage**:
    - Detect GitHub tag creation
    - Build Docker image with new tag
    - Push image to registry
2. **CD Stage**:
    - SSH into target EC2 instance
    - Update Docker Compose file or image tag
    - Pull new image and redeploy
3. **Verification Stage**:
    - Check container status (`docker ps`)
    - Ensure application is reachable via browser or curl

---

## Security 🔒

- Use **environment variables** for sensitive information (SSH keys, registry credentials)
- Do **not** hardcode passwords or keys in the workflow
