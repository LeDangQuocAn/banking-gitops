Edge (business) apps for staging

This directory holds Argo CD Application manifests for the edge microservices that implement business functionality.

Included apps:
- edge-account-app.yaml
- edge-bank-app.yaml
- edge-credit-card-app.yaml
- edge-invoice-app.yaml
- edge-log-app.yaml
- edge-user-app.yaml

Usage:
- These apps depend on core and infra components; sync them after core and infra are healthy.
