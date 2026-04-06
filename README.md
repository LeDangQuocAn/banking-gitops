# Banking Microservices GitOps

This repository stores Kubernetes deployment configuration for the banking microservices platform.
It is organized around reusable Helm charts and per-environment values overlays.

## Repository Structure

```text
banking-gitops/
├── charts/
│   ├── banking-spring-boot/      # Reusable app chart (deploy each service as a release)
│   └── banking-infrastructure/   # Shared infra chart (Postgres/RabbitMQ/Mongo/Redis)
└── environments/
		├── staging/
		│   ├── infra-values.yaml
		│   ├── account-values.yaml
		│   ├── gateway-values.yaml
		│   ├── bank-values.yaml
		│   ├── credit-card-values.yaml
		│   ├── discovery-client-values.yaml
		│   ├── invoice-values.yaml
		│   ├── log-values.yaml
		│   └── user-values.yaml
		└── prod/
				├── infra-values.yaml
				├── account-values.yaml
				├── gateway-values.yaml
				├── bank-values.yaml
				├── credit-card-values.yaml
				├── discovery-client-values.yaml
				├── invoice-values.yaml
				├── log-values.yaml
				└── user-values.yaml
```

## Deployment Model

- One reusable Helm chart (`banking-spring-boot`) is installed 8 times, one release per service.
- `staging` can run in-cluster infrastructure via `banking-infrastructure`.
- `prod` disables in-cluster databases and points applications to external managed services.
- Ingress is the default north-south entry mode.

## Services

- account-service
- api-gateway-service
- bank-service
- credit-card-service
- discovery-client-service
- invoice-service
- log-service
- user-service

## Helm Commands

### 1) Render and lint charts

```bash
helm lint charts/banking-spring-boot
helm lint charts/banking-infrastructure
```

```bash
helm template account-staging charts/banking-spring-boot -f environments/staging/account-values.yaml
helm template account-prod charts/banking-spring-boot -f environments/prod/account-values.yaml
helm template infra-staging charts/banking-infrastructure -f environments/staging/infra-values.yaml
helm template infra-prod charts/banking-infrastructure -f environments/prod/infra-values.yaml
```

### 2) Deploy staging

```bash
kubectl create namespace banking-staging --dry-run=client -o yaml | kubectl apply -f -

helm dependency update charts/banking-infrastructure
helm upgrade --install infra-staging charts/banking-infrastructure \
	-n banking-staging \
	-f environments/staging/infra-values.yaml

helm upgrade --install account-staging charts/banking-spring-boot \
	-n banking-staging \
	-f environments/staging/account-values.yaml

helm upgrade --install gateway-staging charts/banking-spring-boot \
	-n banking-staging \
	-f environments/staging/gateway-values.yaml
```

Repeat the same release pattern for `bank`, `credit-card`, `discovery-client`, `invoice`, `log`, and `user`.

### 3) Deploy prod

```bash
kubectl create namespace banking-prod --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install account-prod charts/banking-spring-boot \
	-n banking-prod \
	-f environments/prod/account-values.yaml

helm upgrade --install gateway-prod charts/banking-spring-boot \
	-n banking-prod \
	-f environments/prod/gateway-values.yaml
```

Prod infrastructure chart should usually not be installed because `environments/prod/infra-values.yaml` is configured for external services.
