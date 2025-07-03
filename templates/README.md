# Kubernetes Application Onboarding Templates

This directory contains templates for onboarding different types of applications to your Kubernetes cluster. These templates are designed to standardize and streamline the process of adding new applications to your cluster using a GitOps approach with Argo CD.

## Template Types

### 1. Deployment App Templates (`/templates/deployment-app/`)

**Use when**: You want to deploy an application directly from a container image.

**Best for**:
- Applications that don't require Helm charts
- Custom applications with simple deployment patterns
- Applications that need direct control over Kubernetes resources

**Key features**:
- Deployment with configurable replicas, resources, and environment variables
- Service for internal cluster communication
- Ingress for external access
- Optional ConfigMap for configuration
- Storage options for both NFS (NAS) and Longhorn (database)

[View Deployment App Templates →](./deployment-app/)

### 2. Helm App Templates (`/templates/helm-app/`)

**Use when**: You want to deploy an application using a Helm chart in a GitOps-friendly way.

**Best for**:
- Applications that are distributed as Helm charts
- Complex applications with many interdependent components
- Applications where you want to leverage Helm's templating capabilities

**Key features**:
- Helmfile for declarative Helm chart configuration
- Values file for customizing the Helm chart
- Makefile for generating the helm-chart.yaml file
- Kustomization for including the generated Helm resources

[View Helm App Templates →](./helm-app/)

### 3. Service Exposure Templates (`/templates/service-exposure-app/`)

**Use when**: You want to expose an existing service running outside of Kubernetes.

**Best for**:
- Services running on other servers in your network
- Adding TLS termination to services that don't natively support HTTPS
- Providing custom domain names for internal services

**Key features**:
- ExternalName service to reference external services
- Traefik IngressRoute for routing and TLS termination
- Optional ServersTransport for TLS re-encryption
- Support for both HTTP and HTTPS external services

[View Service Exposure Templates →](./service-exposure-app/)

## How to Use These Templates

1. Determine which template type is appropriate for your application
2. Create a new directory for your application under `manifests/cluster/`
3. Copy the relevant template files to your new directory
4. Customize the files according to the instructions in the template's README.md
5. Commit the changes to your Git repository for Argo CD to apply

## Template Structure

Each template type follows a similar structure:

```
templates/
├── deployment-app/         # For direct container image deployments
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── configmap.yaml
│   ├── persistent-volume-*.yaml
│   ├── kustomization.yaml
│   └── README.md
│
├── helm-app/               # For Helm chart deployments
│   ├── namespace.yaml
│   ├── helmfile.yaml
│   ├── values.yaml
│   ├── Makefile
│   ├── kustomization.yaml
│   └── README.md
│
└── service-exposure-app/   # For exposing external services
    ├── namespace.yaml
    ├── service.yaml
    ├── ingress.yaml
    ├── serverstransport.yaml
    ├── kustomization.yaml
    └── README.md
```

## Best Practices

1. **One namespace per application**: Each application should have its own namespace for better isolation and management.
2. **Use kustomize**: All templates use kustomization.yaml to compose resources, making it easy to add or remove components.
3. **GitOps workflow**: Templates are designed to work with Argo CD and a GitOps approach.
4. **Documentation**: Always refer to the README.md in each template directory for detailed instructions.
5. **Consistency**: Follow the patterns established in these templates for all new applications to maintain consistency across your cluster.

## Examples

For examples of how these templates are used in practice, see the following directories in the cluster manifests:

- **Deployment App**: See `manifests/cluster/radarr` or `manifests/cluster/vaultwarden`
- **Helm App**: See `manifests/cluster/dapr`
- **Service Exposure**: See `manifests/cluster/jellyfin`, `manifests/cluster/pihole`, or `manifests/cluster/pikvm`
