Core apps for the staging environment

This directory contains Argo CD Application manifests for the "core" microservices that provide shared platform functionality.

Included apps:
- core-api-gateway-app.yaml — API Gateway for internal routing
- core-discovery-client-app.yaml — Service discovery client
- core-shared-secrets-app.yaml — Shared secrets management

Usage:
- Sync these apps via Argo CD to deploy core platform components.
- Deploy order: shared-secrets → discovery-client → api-gateway.

Notes:
- Secrets are managed via the core-shared-secrets-app.yaml Argo CD app (backed by your secrets operator).
