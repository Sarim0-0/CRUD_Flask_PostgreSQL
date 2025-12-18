# Flask CRUD Application - DevOps Project

A containerized Flask CRUD application with PostgreSQL and Redis, deployed on Kubernetes with complete CI/CD pipeline and monitoring.

## 🚀 Quick Start

### Prerequisites

- Python 3.9+
- Docker & Docker Compose
- Minikube & kubectl
- Terraform
- AWS CLI (configured)

---

## 🖥️ Running Locally

```powershell
# Clone repository
git clone <your-repo-url>
cd CRUD_Flask_PostgreSQL

# Create virtual environment
python -m venv .venv
.venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Set environment variables
$env:DATABASE_URL="postgresql://postgres:password@localhost:5432/lin_flask"
$env:REDIS_HOST="localhost"

# Run application
python app.py
```

**Access:** http://localhost:5000

---

## 🐳 Running with Docker Compose

```powershell
# Build and start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

**Services:**
- Flask App: http://localhost:5000
- PostgreSQL: localhost:5432
- Redis: localhost:6379

---

## ☸️ Running on Kubernetes (Minikube)

### Setup

```powershell
# Start Minikube
minikube start --driver=docker

# Use Minikube's Docker
minikube docker-env | Invoke-Expression

# Build image
docker build -t flask-crud-app:latest .
```

### Deploy

```powershell
# Create namespaces
kubectl apply -f k8s/namespaces/

# Deploy application
kubectl apply -f k8s/dev/

# Deploy monitoring
kubectl apply -f k8s/monitoring/

# Verify deployment
kubectl get pods -n dev
kubectl get pods -n monitoring
```

### Access Application

```powershell
# Get service URL
minikube service flask-app-service -n dev --url

# Or port forward
kubectl port-forward -n dev svc/flask-app-service 8080:80
```

**Access:** http://localhost:8080

### Access Monitoring

```powershell
# Prometheus
kubectl port-forward -n monitoring svc/prometheus-service 9090:9090
# Visit: http://localhost:9090

# Grafana (admin/admin123)
kubectl port-forward -n monitoring svc/grafana-service 3000:3000
# Visit: http://localhost:3000
```

---

## ☁️ Infrastructure Setup (Terraform)

### Provision AWS Resources

```powershell
cd infra

# Initialize Terraform
terraform init

# Plan infrastructure
terraform plan -var="db_password=your-secure-password"

# Apply infrastructure
terraform apply -var="db_password=your-secure-password"

# View outputs
terraform output
```

**Resources Created:**
- VPC with public/private subnets
- EC2 instance (t2.micro)
- RDS PostgreSQL database
- Security groups
- Internet Gateway

### Teardown

```powershell
# Destroy all resources
terraform destroy -var="db_password=your-secure-password"

# Verify deletion
aws ec2 describe-instances --filters "Name=tag:Name,Values=crud-flask-*"
```

---

## 🔄 CI/CD Pipeline

Pipeline triggers automatically on push to `sarim-final` or `main` branches.

### Manual Trigger

```powershell
git add .
git commit -m "deploy: trigger CI/CD pipeline"
git push origin sarim-final
```

### Pipeline Stages

1. **Build & Install** - Dependencies installation
2. **Lint & Security** - Code quality and vulnerability scanning
3. **Test** - Unit tests with PostgreSQL/Redis
4. **Docker** - Build and push to Docker Hub
5. **Terraform Validate** - Infrastructure validation
6. **Kubernetes Validate** - Manifest validation
7. **Ansible Validate** - Playbook syntax check
8. **Smoke Tests** - Post-deployment verification

---

## 🛠️ Configuration Management (Ansible)

```powershell
cd ansible

# Run locally via Docker
docker run --rm -it `
  -v "${PWD}:/work" `
  -w /work `
  cytopia/ansible:latest `
  ansible-playbook test-playbook.yaml
```

---

## 📊 Monitoring

- **Prometheus:** Metrics collection and alerting
- **Grafana:** Visualization dashboards
- **Metrics:** CPU, Memory, Pod count, Network traffic

**Import Dashboard:** Grafana Dashboard ID `15760` for Kubernetes metrics

---

## 🧹 Complete Cleanup

```powershell
# Stop Kubernetes
kubectl delete namespace dev prod monitoring
minikube stop
minikube delete

# Stop Docker
docker-compose down -v

# Destroy AWS
cd infra
terraform destroy -var="db_password=your-password"
```

---

## 📁 Project Structure

```
.
├── app.py                      # Flask application
├── docker-compose.yml          # Docker Compose configuration
├── Dockerfile                  # Container image definition
├── requirements.txt            # Python dependencies
├── .github/workflows/
│   └── ci-cd.yml              # CI/CD pipeline
├── k8s/
│   ├── dev/                   # Dev environment manifests
│   ├── prod/                  # Prod environment manifests
│   ├── monitoring/            # Prometheus & Grafana
│   └── namespaces/            # Namespace definitions
├── infra/
│   ├── main.tf               # Terraform main configuration
│   ├── vpc.tf                # VPC resources
│   ├── ec2.tf                # EC2 instance
│   ├── rds.tf                # RDS database
│   └── outputs.tf            # Output values
└── ansible/
    ├── playbook.yaml         # Main Ansible playbook
    ├── inventory/            # Host inventory
    └── roles/                # Ansible roles
```

---

## 🔐 Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:pass@host:5432/db` |
| `REDIS_HOST` | Redis server hostname | `localhost` or `redis-service` |
| `REDIS_PORT` | Redis server port | `6379` |

---

## 📖 Documentation

- [DevOps Report](devops_report.md) - Complete project documentation
- [Architecture Diagram](docs/architecture.png)
- [CI/CD Pipeline](docs/pipeline.png)

---

## 👤 Author

**Your Name**
- Course: DevOps Lab
- Semester: 7th
- Project: Final Exam

---

## 📝 License

This project is for educational purposes.