# 🐙 GitOps & Observability for Banking Microservices

![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)
![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![HashiCorp Vault](https://img.shields.io/badge/Vault-000000?style=for-the-badge&logo=Vault&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=Prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/grafana-%23F46800.svg?style=for-the-badge&logo=grafana&logoColor=white)

This repository serves as the **Single Source of Truth (SSoT)** for deploying and managing the Banking Microservices on Amazon EKS. It implements the GitOps methodology using Argo CD, HashiCorp Vault for secret management, and a robust Observability stack.

The application source code and Infrastructure-as-Code (Terraform) can be found in the companion repository: [Banking-Microservices](https://github.com/LeDangQuocAn/Banking-Microservices).

## 🌟 Key Features

- **Argo CD App-of-Apps:** Automated deployment orchestration of 8 microservices, infrastructure components, and monitoring tools.
- **Sync-Waves Orchestration:** Precisely coordinated startup order (Wave -1: Observability/Secrets -> Wave 0: Infra -> Wave 1: Core -> Wave 2: Edge) to prevent `CrashLoopBackOff` errors.
- **Zero Long-lived Credentials:**
  - **HashiCorp Vault:** Integrated with **AWS KMS Auto-unseal**.
  - **External Secrets Operator (ESO):** Dynamic Kubernetes Secret injection.
  - **IRSA (IAM Roles for Service Accounts):** Strict least-privilege pod-level AWS access via OIDC token exchange.
- **Proactive Observability (PLG Stack):**
  - Automated target scraping via `ServiceMonitor`.
  - **Dashboard-as-Code:** Grafana dashboards provisioned dynamically via labeled `ConfigMaps`.
  - Real-time Slack alerts routed through Prometheus Alertmanager.
- **FinOps Optimized:** Utilizes `emptyDir` and dynamic PVCs for testing environments to eliminate orphaned EBS volumes upon teardown.

## 📂 Repository Structure

```text
├── argocd/                  # ArgoCD App-of-Apps root configurations
│   ├── staging/
│   └── prod/
├── charts/
│   └── banking-spring-boot/ # DRY Common Helm Chart for all microservices
└── environments/            # Environment-specific value overrides
    ├── staging/
    │   ├── account-values.yaml
    │   ├── observability/   # ServiceMonitors, Grafana Dashboards as Code
    │   └── ...
    └── prod/
```

## 🔄 Deployment Flow

Continuous Integration (GitHub Actions) from the main repo pushes a new Docker image to Amazon ECR.

A CI bot automatically updates the respective `values.yaml` in this repository with the new image tag via direct commit for staging or pull request for production.

Argo CD detects the state drift and automatically pulls the changes to synchronize the EKS cluster to the desired state.
