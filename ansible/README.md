# Ansible Configuration Management

This directory contains Ansible playbooks and roles for automating the configuration and deployment of the Flask CRUD application infrastructure.

## 📁 Directory Structure

```
ansible/
├── ansible.cfg              # Ansible configuration file
├── playbook.yaml            # Main playbook for EC2 and Kubernetes
├── test-playbook.yaml       # Local test playbook (no SSH required)
├── inventory/
│   └── hosts.ini            # Inventory file defining target hosts
├── roles/
│   ├── docker/              # Docker installation and configuration
│   ├── flask-app/           # Flask application deployment
│   └── monitoring/          # Monitoring stack verification
├── group_vars/
│   ├── all.yml              # Variables for all hosts
│   ├── dev.yml              # Development environment variables
│   └── prod.yml             # Production environment variables
└── host_vars/               # Host-specific variables (optional)
```

## 🚀 Prerequisites

1. **Install Ansible:**
   ```powershell
   pip install ansible
   ```

2. **For EC2 Access (Optional):**
   - Update `inventory/hosts.ini` with your SSH key path
   - Ensure your SSH key has proper permissions
   - EC2 instance must allow SSH from your IP

## 📝 Usage

### Option 1: Run Local Test (No SSH Required) ✅ RECOMMENDED FIRST

This tests your Ansible setup and verifies Kubernetes/Docker locally:

```powershell
cd ansible
ansible-playbook test-playbook.yaml
```

This will:
- ✅ Verify Ansible installation
- ✅ Check Minikube status
- ✅ List Kubernetes namespaces
- ✅ Show pods in dev and monitoring namespaces
- ✅ Display services in dev namespace
- ✅ Check Docker installation

### Option 2: Run Full Playbook (Requires EC2 SSH Access)

**Before running, update `inventory/hosts.ini`:**
```ini
ansible_ssh_private_key_file=C:\path\to\your\key.pem
```

Then run:

```powershell
# Run entire playbook
ansible-playbook -i inventory/hosts.ini playbook.yaml

# Run specific tags only
ansible-playbook -i inventory/hosts.ini playbook.yaml --tags "docker"
ansible-playbook -i inventory/hosts.ini playbook.yaml --tags "k8s"
ansible-playbook -i inventory/hosts.ini playbook.yaml --tags "app"

# Check what would change (dry-run)
ansible-playbook -i inventory/hosts.ini playbook.yaml --check

# Run with verbose output
ansible-playbook -i inventory/hosts.ini playbook.yaml -v
```

### Option 3: Run Specific Roles

```powershell
# Test connectivity
ansible all -i inventory/hosts.ini -m ping

# Run only on EC2 instances
ansible-playbook -i inventory/hosts.ini playbook.yaml --limit ec2_instances

# Run only Kubernetes tasks
ansible-playbook -i inventory/hosts.ini playbook.yaml --limit kubernetes
```

## 🏷️ Available Tags

- `system` - System package updates
- `packages` - Install system packages
- `docker` - Docker installation and configuration
- `app` - Flask application setup
- `python` - Python dependencies
- `k8s` - Kubernetes operations
- `pods` - Kubernetes pod operations
- `services` - Kubernetes service operations
- `monitoring` - Monitoring stack verification
- `health` - Health checks

Example:
```powershell
ansible-playbook -i inventory/hosts.ini playbook.yaml --tags "docker,app"
```

## 📋 What Each Playbook Does

### `test-playbook.yaml` (Local - No SSH)
1. Verifies Ansible installation
2. Checks Minikube and kubectl
3. Lists Kubernetes resources
4. Verifies Docker installation
5. Displays system information

### `playbook.yaml` (Remote EC2 + Local K8s)
1. **EC2 Configuration:**
   - Updates system packages
   - Installs Docker and Docker Compose
   - Installs Python dependencies
   - Creates application directory
   - Configures Flask environment

2. **Kubernetes Operations:**
   - Verifies Minikube status
   - Lists pods and services
   - Checks monitoring namespace

3. **Application Deployment:**
   - Creates environment files
   - Configures systemd service
   - Validates Docker installation

4. **Health Checks:**
   - Pings all servers
   - Validates configuration

## 🔐 Security Notes

1. **SSH Keys:** Never commit private keys to Git
2. **Passwords:** Use `ansible-vault` for sensitive data:
   ```powershell
   ansible-vault encrypt group_vars/dev.yml
   ansible-vault edit group_vars/dev.yml
   ```
3. **Database Passwords:** Update in encrypted vault files

## 🧪 Testing

1. **Test Inventory:**
   ```powershell
   ansible-inventory -i inventory/hosts.ini --list
   ```

2. **Test Connectivity:**
   ```powershell
   ansible all -i inventory/hosts.ini -m ping
   ```

3. **Dry Run:**
   ```powershell
   ansible-playbook -i inventory/hosts.ini playbook.yaml --check
   ```

## 📊 Expected Output

### Successful Test Playbook Run:
```
PLAY [Test Ansible Configuration] ***************

TASK [Display Ansible version] ******************
ok: [localhost]

TASK [Check Minikube status] ********************
ok: [localhost]

PLAY RECAP **************************************
localhost    : ok=12   changed=0   unreachable=0   failed=0
```

### Successful Main Playbook Run:
```
PLAY RECAP **************************************
flask-app-server : ok=15   changed=5   unreachable=0   failed=0
minikube-cluster : ok=8    changed=0   unreachable=0   failed=0
```

## 🔧 Troubleshooting

### Issue: "Permission denied (publickey)"
**Solution:** Update SSH key path in `inventory/hosts.ini`

### Issue: "Host key verification failed"
**Solution:** Already disabled in `ansible.cfg` with `host_key_checking = False`

### Issue: "Module not found"
**Solution:** Install required Python modules:
```powershell
pip install ansible paramiko
```

### Issue: "Connection timeout"
**Solution:** Check EC2 security group allows SSH (port 22) from your IP

## 📸 Screenshots Required for Report

1. Run test playbook and capture output
2. Run main playbook with verbose flag
3. Show inventory list
4. Show successful task completion

## 🎯 Next Steps

1. ✅ Run `test-playbook.yaml` to verify setup
2. 📸 Take screenshots of successful run
3. 🔐 Update SSH key in `hosts.ini` (if running EC2 tasks)
4. 🚀 Run main `playbook.yaml`
5. 📸 Screenshot the PLAY RECAP
6. 📝 Add to `devops_report.md`

## 📚 Additional Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Ansible Galaxy](https://galaxy.ansible.com/) - Community roles
