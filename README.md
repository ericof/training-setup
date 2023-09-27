# Training Environment Setup

This repository contains Ansible playbooks designed to automate the process of setting up a training environment. Given a list of student GitHub usernames, it will:

- Create a separate Digital Ocean droplet for each student
- Register a DNS entry on Cloudflare that points to each student's droplet

## 📋 Requirements

- **Digital Ocean Account:** You need a Digital Ocean account and a [Personal Access Token](https://cloud.digitalocean.com/account/api) with **WRITE** permissions.
- **Cloudflare Account:** A Cloudflare account is required, configured with a valid domain name. You also need an [API Token](https://dash.cloudflare.com/profile/api-tokens) with **Zone DNS** permissions.

## ⚙️ Installation

### 1. Clone the Repository

Clone this repository to your local machine and navigate into the directory:

```shell
git clone git@github.com:ericof/training-setup.git
cd training-setup
```

### 2. Set Environment Variables

Copy the `.env_dist` file to `.env` and replace all **change-me** placeholders with your actual values. Here’s what each variable is for:

| Variable | Description |
| -------- | ----------- |
| **DO_API_TOKEN** | Your Digital Ocean API token |
| **CLOUDFLARE_TOKEN** | Your Cloudflare API token |
| **DOMAIN_NAME** | The domain name used to create entries (must be configured in Cloudflare), e.g., `tangrama.com.br` |
| **TRAINING_PREFIX** | Prefix for creating droplets and hostnames, e.g., `ploneconf2023` |

### 3. Install Ansible

Execute the following command to install Ansible along with the necessary dependencies:

```shell
make build
```

## 🚀 Usage

### Configure the Students List

Open the `inventory/group_vars/all/students.yml` file and add the GitHub usernames of your students:

```yaml
---
students:
  - ericof
  - polyester
  - sneridagh
```

This information is used to:

- Create a droplet and a DNS entry for each student
- Download their SSH keys and assign them to the **root** user on their respective droplets

### Verify Digital Ocean Inventory

Execute `make list-environment` to verify if your **DO_API_TOKEN** is configured correctly. You should see an output similar to the one below:

```
==> List training environment
./bin/ansible-playbook playbooks/inventory.yml

PLAY [List Training Environment Droplets] ************************************************************************************************************************************************************************

TASK [List all droplets] *****************************************************************************************************************************************************************************************
skipping: [localhost]

PLAY RECAP *******************************************************************************************************************************************************************************************************
localhost                  : ok=0    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

### Create the Training Environment

Execute the following command to create a droplet and a DNS entry for each student:

```shell
make create-environment
```

For instance, if `TRAINING_PREFIX=ploneconf2023` and `DOMAIN_NAME=plone-training.com`, the droplets created will be:

- `ploneconf2023-ericof.plone-training.com`
- `ploneconf2023-polyester.plone-training.com`
- `ploneconf2023-sneridagh.plone-training.com`

You can verify the IP addresses of each droplet by running `make list-environment`.

### Destroy the Training Environment

To clean up and remove all droplets, SSH keys, and DNS entries, execute:

```shell
make destroy-environment
```


## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check [issues page](https://github.com/ericof/training-setup/issues)
