# Service Exposure Application Template

This template provides a starting point for exposing external services (running outside of Kubernetes) through your Kubernetes cluster with Traefik IngressRoutes. It's designed for services that are already running elsewhere on your network that you want to expose with TLS termination and custom domain names.

## Use Cases

This template is ideal for:
- Exposing services running on other servers in your network
- Adding TLS termination to services that don't natively support HTTPS
- Providing custom domain names for internal services
- Creating a unified access point for various services

## How to Use This Template

1. Create a new directory for your application under `manifests/cluster/`
2. Copy the template files to your new directory
3. Customize the files as described below
4. Commit all files to your Git repository for Argo CD to apply

## Template Files

### namespace.yaml
Creates a dedicated namespace for your service exposure.
- **Customize**: Change `{{APP_NAME}}` to your application name

### service.yaml
Creates an ExternalName service that points to your external service.
- **Customize**:
  - Replace `{{APP_NAME}}` with your application name
  - Replace `{{EXTERNAL_IP}}` with the IP address of your external service
  - Replace `{{PORT}}` with the port your service is running on
  - Replace `{{SSL_SUFFIX}}` with `-ssl` if your service uses HTTPS, or leave empty for HTTP services

### ingress.yaml
Creates a Traefik IngressRoute to expose your service with a custom domain name.
- **Customize**:
  - Replace `{{APP_NAME}}` with your application name
  - Replace `{{DOMAIN}}` with your desired domain name
  - Replace `{{PATH_PREFIX}}` with `&& PathPrefix(\`/\`)` or leave empty if not needed
  - Replace `{{PORT}}` with the port your service is running on
  - Replace `{{SSL_SUFFIX}}` with `-ssl` if your service uses HTTPS, or leave empty for HTTP services
  - Uncomment the scheme and serversTransport lines for HTTPS services

### serverstransport.yaml
Creates a Traefik ServersTransport for TLS re-encryption (only needed for HTTPS services).
- **Customize**:
  - Replace `{{APP_NAME}}` with your application name
  - Only include this file if your external service uses HTTPS

### kustomization.yaml
Defines which resources to apply when deploying your application.
- **Customize**: Uncomment the serverstransport.yaml line if your service uses HTTPS

## Examples

### HTTP Service (like Jellyfin)

For a service running on HTTP:

1. Replace `{{APP_NAME}}` with `jellyfin`
2. Replace `{{EXTERNAL_IP}}` with `10.0.0.150`
3. Replace `{{PORT}}` with `8096`
4. Replace `{{DOMAIN}}` with `jellyfin.example.com`
5. Leave `{{SSL_SUFFIX}}` empty
6. Leave the scheme and serversTransport lines commented out
7. Do not include serverstransport.yaml in kustomization.yaml

### HTTPS Service (like PiKVM)

For a service running on HTTPS:

1. Replace `{{APP_NAME}}` with `pikvm`
2. Replace `{{EXTERNAL_IP}}` with `10.0.0.175`
3. Replace `{{PORT}}` with `443`
4. Replace `{{DOMAIN}}` with `pikvm.example.com`
5. Replace `{{SSL_SUFFIX}}` with `-ssl`
6. Uncomment the scheme and serversTransport lines
7. Include serverstransport.yaml in kustomization.yaml

## Notes

- This template assumes you're using Traefik as your ingress controller
- The `kubernetes.io/ingress.class: traefik-external` annotation is used to route traffic through your external Traefik instance
- For HTTPS services, the ServersTransport with `insecureSkipVerify: true` is used to handle self-signed certificates
- You can add middleware resources if needed for additional functionality like authentication or redirects
