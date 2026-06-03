Infrastructure apps for staging

This directory contains the Argo CD Application manifest that deploys infrastructure-level components used by the staging environment.

Included app:
- infra-app.yaml — central Argo CD Application for infrastructure resources (namespaces, ingress controllers, storage classes, etc.)

Usage:
- Sync `infra-app.yaml` first to ensure required namespaces and cluster-level resources exist.

Notes:
- Review the app's target namespace and cluster-scoped resources before sync.
