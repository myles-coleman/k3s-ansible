# Helm Application Template

This template provides a starting point for deploying applications that use Helm charts to your Kubernetes cluster using a GitOps approach with Argo CD. Instead of applying Helm charts directly, this template uses helmfile to template out the Helm chart into a `helm-chart.yaml` file that can be included in your kustomization.

## How to Use This Template

1. Create a new directory for your application under `manifests/cluster/`
2. Copy the template files to your new directory
3. Customize the files as described below
4. Run `make` to generate the `helm-chart.yaml` file
5. Commit all files to your Git repository for Argo CD to apply

## Template Files

### namespace.yaml
Creates a dedicated namespace for your application.
- **Customize**: Change `{{APP_NAME}}` to your application name

### helmfile.yaml
Defines the Helm chart repository and release configuration.
- **Customize**:
  - Update `{{REPO_NAME}}` with the Helm repository name
  - Update `{{REPO_URL}}` with the Helm repository URL
  - Set `{{APP_NAME}}` to your application name
  - Set `{{CHART_VERSION}}` to the desired chart version
  - Set `{{CHART_NAME}}` to the chart name
  - Adjust the values section if using values files

### values.yaml
Contains the default values for the Helm chart.
- **Customize**: Replace the example configuration with the actual values needed for your application

### Makefile
Automates the process of generating the helm-chart.yaml file from helmfile and values files.
- **Customize**: Generally no customization needed, but you can adjust if you have special requirements

### kustomization.yaml
Defines which resources to apply when deploying your application.
- **Customize**: Add any additional resources if needed

## Example Usage

To deploy a new Helm-based application called "my-app":

1. Create the application directory:
   ```bash
   mkdir -p /home/bee/k3s-ansible/manifests/cluster/my-app
   ```

2. Copy the template files:
   ```bash
   cp /home/bee/k3s-ansible/templates/helm-app/* /home/bee/k3s-ansible/manifests/cluster/my-app/
   ```

3. Customize each file as needed for your application

4. Generate the helm-chart.yaml file:
   ```bash
   cd /home/bee/k3s-ansible/manifests/cluster/my-app/
   make
   ```

5. Commit the changes to your Git repository for Argo CD to apply

## Notes

- The `helm-chart.yaml` file is generated from the helmfile and values files and should not be edited directly
- Always regenerate the `helm-chart.yaml` file after changing helmfile.yaml or any values files
- The Makefile automatically finds all values files (values.yaml, values-*.yaml) and includes them in the templating process
- For complex Helm charts, you may need to add additional resources to the kustomization.yaml file
