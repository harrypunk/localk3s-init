# K3s Air-Gap Installation with Ansible (HA with kube-vip)

This repository contains Ansible playbooks and configuration files for deploying a highly available K3s cluster in an air-gapped environment, using `kube-vip` for a virtual IP.

## Features

- High Availability (HA) K3s cluster setup with embedded etcd.
- Control plane Virtual IP (VIP) management using `kube-vip`.
- Air-gap deployment support.
- Uses local DNS names (`linux1.lan`, `linux2.lan`) for nodes.
- Configures API server to be accessible via `k3s.lan`.

## Files Included

- `inventory.ini` - Ansible inventory file defining your K3s servers
- `k3s-install.yml` - Main playbook for installing K3s HA servers
- `templates/k3s.service.j2` - Systemd service template for K3s server
- `templates/kube-vip.yaml.j2` - Template for the `kube-vip` manifest

## Prerequisites

1. Ansible installed on your control machine
2. SSH access to target nodes (`linux1.lan`, `linux2.lan`)
3. K3s binary and air-gap images tar file available via HTTP URLs
4. `kube-vip` Docker image (`ghcr.io/kube-vip/kube-vip`) available in your air-gapped environment (imported into nodes' local Docker registry or containerd)
5. Local DNS resolution configured for `linux1.lan`, `linux2.lan`, and `k3s.lan` (pointing to the VIP, e.g., 192.168.1.100)

## Usage

### 1. Inventory Configuration

Update the `inventory.ini` file to list your HA servers:
```ini
[k3s_servers]
linux1.lan
linux2.lan
```

### 2. Configure Download URLs

Before running the playbook, you need to set the URLs for the K3s binary and air-gap images:
- `k3s_binary_url`: URL to download the K3s binary (defaults to latest GitHub release)
- `k3s_airgap_images_url`: URL to download the K3s air-gap images tar file

You can override these variables during playbook execution:
```bash
ansible-playbook -i inventory.ini k3s-install.yml -e "k3s_binary_url=http://tmp.file.lan/k3s k3s_airgap_images_url=http://tmp.file.lan/k3s-airgap-images.tar.zst"
```

Execute the main playbook to set up the HA cluster:
```bash
ansible-playbook -i inventory.ini k3s-install.yml
```
This will:
- Install K3s on `linux1.lan` as the first server (with `--cluster-init`).
- Install K3s on `linux2.lan`, joining it to the first server.
- Deploy `kube-vip` as a static pod on the control plane nodes.
- Configure the K3s API server certificate to be valid for `k3s.lan`.

### 3. Accessing the Cluster

After installation, the kubeconfig file will be fetched to `./kubeconfig`. The server address in this file might need to be updated to `https://k3s.lan:6443`.

```bash
# Export the kubeconfig
export KUBECONFIG=./kubeconfig

# IMPORTANT: Edit the kubeconfig file to change the server address to:
# server: https://k3s.lan:6443
# Or set it directly in your environment:
kubectl config set-cluster default --server=https://k3s.lan:6443

# Verify the cluster nodes
kubectl get nodes
```

## Customization

- **K3s Binary and Air-gap Images URLs**: Modify the `k3s_binary_url` and `k3s_airgap_images_url` variables in `k3s-install.yml` or override them during playbook execution.
- **VIP Configuration**: The VIP address (`192.168.1.100`) and network interface (`eth0`) are currently hardcoded in `k3s-install.yml`. You can make these configurable via `group_vars` or `host_vars`.
- **Service Parameters**: Adjust service parameters in the template files as needed.
- **Additional K3s Arguments**: Add additional K3s server arguments in the `ExecStart` line of `templates/k3s.service.j2`.
- **kube-vip Image**: The `kube-vip` image tag is defined in `templates/kube-vip.yaml.j2`. Update it to the desired version and ensure it's available in your air-gapped environment.