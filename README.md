# K3s Air-Gap Installation with Ansible (HA with kube-vip)

This Ansible playbook installs K3s in an air-gapped environment with HA using kube-vip. The playbook now uses FQDN format for all Ansible modules, follows best practices for boolean values, and includes improved task naming for better debugging.

## Changes

- Updated all Ansible modules in `k3s-install.yml` to use FQDN format (e.g., `ansible.builtin.copy` instead of `copy`)
- Updated boolean values in `k3s-install.yml` to use `true`/`false` instead of `yes`/`no`
- Updated task names in `k3s-install.yml` to include `{{ inventory_hostname }}` for better identification
- Updated `k3s.service.j2` template to use `{{ inventory_hostname }}` for the `--tls-san` parameter instead of hardcoded `k3s.lan`

