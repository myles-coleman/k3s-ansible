# Deployment App Template

This template provides a starting point for deploying applications that use a container image to your Kubernetes cluster. Use this template for applications that are deployed directly from a container image rather than using Helm charts.

## How to Use This Template

1. Create a new directory for your application under `manifests/cluster/`
2. Update the kustomization file under `manifests/cluster/` to include the new application directory
3. Copy the template files to your new directory
4. Customize the files as described below

## Template Files

### namespace.yaml
Creates a dedicated namespace for your application.
- **Customize**: Change `app-name` to your application name

### service.yaml
Creates a service to expose your application within the cluster or to external systems.
- **Customize**: Update service name, namespace, selector labels, and ports

### ingress.yaml
Creates an IngressRoute to expose your application via HTTPS with a domain name.
- **Customize**:
  - Update namespace
  - Change the hostname (`example.domain.com`)
  - Update service name and port to match your service

### deployment.yaml
Defines the deployment for your application including container image, resources, and volumes.
- **Customize**:
  - Update namespace, labels, and name
  - Set the container image and tag
  - Configure resource limits
  - Add environment variables
  - Configure volume mounts if needed

### configmap.yaml (optional)
Provides configuration data for your application.
- **Customize**:
  - Update namespace and name
  - Add your application's configuration data

### kustomization.yaml
Defines which resources to apply when deploying your application.
- **Customize**: Add or remove resources as needed for your application

### persistent-volume-nfs.yaml (optional)
Defines a persistent volume that uses NFS storage for applications that need to access data on your NAS.
- **Customize**:
  - Update the volume name
  - Set the storage size
  - The default path is `/mnt/md0/data` on server `10.0.0.150`

### persistent-volume-claim-nfs.yaml (optional)
Creates a claim for the NFS persistent volume.
- **Customize**:
  - Update namespace and name
  - Set the storage size (must match the PV)
  - Set the volume name to match your PV

### persistent-volume-claim-longhorn.yaml (optional)
Creates a persistent volume claim using Longhorn storage (ideal for databases and application state).
- **Customize**:
  - Update namespace and name
  - Set the appropriate storage size for your application

## Example Usage

To deploy a new application called "my-app":

1. Create the application directory:
   ```bash
   mkdir -p /home/bee/k3s-ansible/manifests/cluster/my-app
   ```

2. Copy the template files:
   ```bash
   cp /home/bee/k3s-ansible/templates/deployment-app/*.yaml /home/bee/k3s-ansible/manifests/cluster/my-app/
   ```

3. Customize each file as needed for your application

4. Apply the configuration:
   ```bash
   kubectl apply -k /home/bee/k3s-ansible/manifests/cluster/my-app/
   ```

## Storage Options

### NFS Storage (for Media and Large Data)
Use this option when your application needs to access media files or large datasets stored on your NAS:

1. Enable the NFS persistent volume and claim in `kustomization.yaml`:
   ```yaml
   resources:
     - namespace.yaml
     - deployment.yaml
     - service.yaml
     - ingress.yaml
     - persistent-volume-nfs.yaml
     - persistent-volume-claim-nfs.yaml
   ```

2. Update your deployment to mount the volume:
   ```yaml
   volumeMounts:
   - name: data
     mountPath: /path/in/container
   volumes:
   - name: data
     persistentVolumeClaim:
       claimName: app-name-data
   ```

### Longhorn Storage (for Databases)
Use this option for applications that need persistent storage for databases or application state:

1. Enable the Longhorn persistent volume claim in `kustomization.yaml`:
   ```yaml
   resources:
     - namespace.yaml
     - deployment.yaml
     - service.yaml
     - ingress.yaml
     - persistent-volume-claim-longhorn.yaml
   ```

2. Update your deployment to mount the volume:
   ```yaml
   volumeMounts:
   - name: data
     mountPath: /path/in/container
   volumes:
   - name: data
     persistentVolumeClaim:
       claimName: app-name-data
   ```

## Notes

- For applications that need specific network policies, add a NetworkPolicy resource
- Remember to update the kustomization.yaml to include any additional resources you add
