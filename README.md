# kubeans
A solution for a simple highly available kubernetes cluster on AWS infrastructure, provisioned with OpenTofu andconfigured using Ansble.

## Usage
### 📦 Requirements

- OpenTofu >= 1.12
- Ansible

### Infrastructure Provisioning
#### AWS Login
In order to run the playbook, we have to be logged in on our AWS account. We can either log in via the awscli or by setting the following environmental variables:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

#### OpenTofu Initialization 
Make sure you have `versions.tf` file locally with **hashicorp/aws** and **hashicorp/local** providers and run the following command to install them:
```bash
tofu init
```

#### Apply .tf Files
Make sure you have the `main.tf` before running the following command to start the provisioning procedure:
```bash
tofu apply
```
This command will list all the resources to be provisioned, take a look and if everything looks fine, type yes.

If you do not want open tofu to list the resources and wait for you input, you can add the -auto-approve flag:
```bash
tofu apply -auto-approve
```

### Kubernetes Cluster Configuration
This repository's `hosts.yml` file is not correct and will not work for your infrastructure. OpenTofu automates the creation of that file with the correct node topology for high availability - basically scatters the nodes (especially control planes) to different availability zones. That file, in the case of a five node cluster, can look like the following:
```yaml
---
control_plane_nodes:
  hosts:
    controlplane1:
      ansible_host: <ip-az1>
      ansible_port: 22
      ansible_ssh_user: ubuntu
      ansible_ssh_private_key_file: <ssh-key-path>
    controlplane1:
      ansible_host: <ip-az2>
      ansible_port: 22
      ansible_ssh_user: ubuntu
      ansible_ssh_private_key_file: <ssh-key-path>
    controlplane1:
      ansible_host: <ip-az3>
      ansible_port: 22
      ansible_ssh_user: ubuntu
      ansible_ssh_private_key_file: <ssh-key-path>
worker_nodes:
  hosts:
    worker1:
      ansible_host: <ip-az1>
      ansible_port: 22
      ansible_ssh_user: ubuntu
      ansible_ssh_private_key_file: <ssh-key-path>
   worker2:
      ansible_host: <ip-az2>
      ansible_port: 22
      ansible_ssh_user: ubuntu
      ansible_ssh_private_key_file: <ssh-key-path>
```

#### Running the Playbook
Make sure you have this file after the infrastructure provisioning part and then run the main ansible playbook:
```bash
ansible-playbook playbooks/main.yml
```

### Access Kubernetes Cluster
After the ansible playbook has finished, every node will container a kubeconfig file, pointing to the public load balancer, with admin priviledges in `/home/ubuntu/.kube/externalconf`.

You can copy that file locally, either using `scp` or copying it by hand, to access the cluster from your machine.