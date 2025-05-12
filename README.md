# Docker Node.js Image for CI/CD Pipelines

This project provides a Docker image that combines Docker CLI with Node.js 20.x, designed specifically for CI/CD pipelines that need both Node.js for building applications and Docker for containerization tasks.

## Overview

The `keviocastro/docker-node:20` image is built on top of the official `docker:latest` Alpine-based image with Node.js 20.x added. This makes it ideal for CI/CD pipelines where you need to:

- Build and test Node.js applications
- Create Docker images
- Push Docker images to registries
- Run Docker commands within pipelines

## Included Tools and Versions

- Docker: Latest version from the official Docker image
- Node.js: v20.x (currently v20.15.1)
- npm: Included with Node.js
- Other utilities: bash, curl

## Using in GitLab CI/CD

### Basic Example

```yaml
# .gitlab-ci.yml
stages:
  - build
  - test
  - deploy

build:
  stage: build
  image: keviocastro/docker-node:20
  services:
    - docker:dind
  variables:
    DOCKER_HOST: tcp://docker:2376
    DOCKER_TLS_CERTDIR: "/certs"
  script:
    - npm ci
    - npm run build
    - docker build -t myapp:${CI_COMMIT_SHORT_SHA} .
    - docker tag myapp:${CI_COMMIT_SHORT_SHA} registry.example.com/myapp:${CI_COMMIT_SHORT_SHA}
    - docker push registry.example.com/myapp:${CI_COMMIT_SHORT_SHA}
  artifacts:
    paths:
      - dist/
```

### Building and Publishing a Node.js Application

```yaml
# .gitlab-ci.yml
build_and_publish:
  image: keviocastro/docker-node:20
  services:
    - docker:dind
  variables:
    DOCKER_HOST: tcp://docker:2376
    DOCKER_TLS_CERTDIR: "/certs"
  script:
    # Install dependencies
    - npm ci
    # Run tests
    - npm test
    # Build the application
    - npm run build
    # Build and push Docker image
    - echo $CI_REGISTRY_PASSWORD | docker login -u $CI_REGISTRY_USER $CI_REGISTRY --password-stdin
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
    # If on main branch, also tag as latest
    - if [ "$CI_COMMIT_REF_NAME" = "main" ]; then
    -   docker tag $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG $CI_REGISTRY_IMAGE:latest
    -   docker push $CI_REGISTRY_IMAGE:latest
    - fi
```

## Using in GitHub Actions

### Basic Example

```yaml
# .github/workflows/build-and-deploy.yml
name: Build and Deploy

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    container: keviocastro/docker-node:20

    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Docker
      uses: docker/setup-buildx-action@v1
      
    - name: Build application
      run: |
        npm ci
        npm run build
        
    - name: Build and push Docker image
      uses: docker/build-push-action@v2
      with:
        context: .
        push: ${{ github.event_name != 'pull_request' }}
        tags: ghcr.io/${{ github.repository }}:${{ github.sha }}
```

### Node.js Application with Docker Multi-Stage Build

```yaml
# .github/workflows/node-docker.yml
name: Node.js Docker Build

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Build and deploy
      uses: docker/build-push-action@v2
      with:
        context: .
        push: true
        tags: |
          ghcr.io/${{ github.repository }}:${{ github.sha }}
          ghcr.io/${{ github.repository }}:latest
```

## Common Use Cases

### Running Node.js tests and building a Docker image

```yaml
# GitLab example
test_and_build:
  image: keviocastro/docker-node:20
  services:
    - docker:dind
  script:
    - npm ci
    - npm test
    - docker build -t myapp:latest .
```

### Frontend build and containerization

```yaml
# GitHub Actions example
build_frontend:
  runs-on: ubuntu-latest
  container: keviocastro/docker-node:20
  
  steps:
  - uses: actions/checkout@v3
  
  - name: Install dependencies
    run: npm ci
    
  - name: Build frontend
    run: npm run build
    
  - name: Build container
    run: |
      docker build -t mycompany/frontend:${{ github.sha }} -f Dockerfile.prod .
      echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
      docker push mycompany/frontend:${{ github.sha }}
```

### Full-stack application deployment

```yaml
# GitLab example
deploy_fullstack:
  image: keviocastro/docker-node:20
  services:
    - docker:dind
  script:
    - npm ci
    - npm run build
    - docker-compose build
    - docker-compose push
    - kubectl apply -f k8s/deployment.yml
```

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
