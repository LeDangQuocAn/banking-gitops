Observability apps for staging

This directory contains Argo CD Application manifests for observability tooling deployed to the cluster.

Included apps:
- kube-prometheus-stack-app.yaml — Prometheus + Grafana stack for metrics
- loki-stack-app.yaml — Loki stack for log collection and storage

Usage:
- Deploy observability after infra (storage, namespaces) are available.
- Configure Grafana datasources and dashboards as required.
