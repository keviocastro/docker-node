# Bastion Host Docker Image

This project provides a simple bastion host Docker image based on Ubuntu 20.04 with SSH server installed. A bastion host serves as a secure entry point for accessing resources in a private network.

## Overview

The `keviocastro/bastion` image is a minimal Ubuntu 20.04 installation with OpenSSH server configured and ready to use as a jump server or bastion host.

## Getting Started

### Prerequisites

- Docker
- Docker Compose

### Usage

1. Clone this repository:

```bash
git clone https://github.com/keviocastro/bastion.git
cd bastion
```

2. Build the Docker image:

```bash
docker-compose build
```

3. Start the bastion container:

```bash
docker-compose up -d
```

4. The SSH service will be available on port 22 of your host machine.

## Configuration

### SSH Access

By default, the container runs an SSH server. You'll need to configure SSH access by either:

- Mounting SSH authorized keys
- Setting up password authentication (not recommended for production)

### Example: Adding SSH Keys

Update the docker-compose.yml file to mount your SSH authorized_keys:

```yml
services:
  bastion:
    # ... existing configuration ...
    volumes:
      - ./ssh/authorized_keys:/root/.ssh/authorized_keys
```

## Kubernetes Deployment

You can also deploy this bastion host in a Kubernetes cluster. Here's how:

### 1. Push the Docker image to a registry

After building the image locally, push it to a container registry:

```bash
docker tag keviocastro/bastion your-registry/keviocastro/bastion:latest
docker push your-registry/keviocastro/bastion:latest
```

### 2. Create a ConfigMap for SSH authorized keys (optional)

```bash
kubectl create configmap ssh-keys --from-file=authorized_keys=/path/to/your/authorized_keys
```

### 3. Deploy using a Kubernetes manifest

Create a file named `bastion-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bastion
  labels:
    app: bastion
spec:
  replicas: 1
  selector:
    matchLabels:
      app: bastion
  template:
    metadata:
      labels:
        app: bastion
    spec:
      containers:
      - name: bastion
        image: keviocastro/bastion:latest
        ports:
        - containerPort: 22
        volumeMounts:
        - name: ssh-keys
          mountPath: /root/.ssh/authorized_keys
          subPath: authorized_keys
      volumes:
      - name: ssh-keys
        configMap:
          name: ssh-keys
---
apiVersion: v1
kind: Service
metadata:
  name: bastion
spec:
  selector:
    app: bastion
  ports:
  - port: 22
    targetPort: 22
  type: LoadBalancer  # Or NodePort, depending on your cluster setup
```

### 4. Apply the manifest

```bash
kubectl apply -f bastion-deployment.yaml
```

### 5. Access the bastion host

If using LoadBalancer:
```bash
ssh -i your_private_key root@$(kubectl get service bastion -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

If using NodePort:
```bash
ssh -i your_private_key root@<node-ip> -p $(kubectl get service bastion -o jsonpath='{.spec.ports[0].nodePort}')
```

### 6. Security considerations for Kubernetes

- Use Kubernetes Secrets instead of ConfigMaps for sensitive data in production
- Consider using Network Policies to restrict access to and from the bastion host
- Implement RBAC to control who can access the bastion pod
- Consider using a StatefulSet if you need persistent storage

## Customization

You can customize the image by modifying the Dockerfile or docker-compose.yml file according to your requirements.

## Security Considerations

- Always use SSH key authentication instead of passwords
- Restrict SSH access to specific IP addresses when possible
- Consider implementing additional security measures like fail2ban
- Regularly update the container to get the latest security patches

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.