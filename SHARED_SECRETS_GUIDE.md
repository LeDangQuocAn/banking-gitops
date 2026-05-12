# Shared Secrets GitOps Solution

## Overview

This solution provisions shared `ExternalSecret` resources that pull credentials from a Vault backend and make them available to all microservices in the `banking` namespace.

## Architecture

- **Chart**: `charts/shared-secrets/` - Minimal Helm chart with ExternalSecret templates
- **Values**: `environments/staging/shared-secrets-values.yaml` - Staging environment configuration
- **ArgoCD App**: `argocd/staging/apps/core/core-shared-secrets-app.yaml` - Deployment manifest
- **Namespace**: `banking` - Where secrets are created
- **Secret Store**: `vault-backend` (ClusterSecretStore) - Vault backend reference

## Provisioned Secrets

### 1. **staging-rds-credentials**
- **Vault Path**: `banking/rds`
- **Fields**: username, password, engine, host, port, dbname
- **Used By**: account-service, bank-service, credit-card-service, invoice-service, user-service

### 2. **staging-elasticache-credentials**
- **Vault Path**: `banking/redis`
- **Fields**: username, password, host, port
- **Used By**: Cache-enabled services

### 3. **infra-staging-rabbitmq**
- **Vault Path**: `banking/rabbitmq`
- **Fields**: username, password, host, port
- **Used By**: Event-driven services (invoice-service, log-service) and the RabbitMQ broker in `banking-infra`

## Deployment Workflow

1. **Bootstrap**: The root-application.yaml (recursive discovery) will discover `core-shared-secrets-app.yaml`
2. **Sync-Wave**: Set to `-1` to ensure shared secrets deploy **before** all other apps
3. **Sync**: ArgoCD applies the Helm chart, which renders ExternalSecret manifests
4. **Vault Sync**: External Secrets Operator watches the ClusterSecretStore and syncs Vault secrets to K8s Secrets

RabbitMQ credentials are rendered into both `banking` and `banking-infra` so the Spring Boot apps and the Bitnami RabbitMQ release consume the same Vault-backed password.

## Mounting Secrets in Pods

### For Spring Boot Microservices

Update the Helm values for each service (e.g., `environments/staging/account-values.yaml`):

```yaml
# environments/staging/account-values.yaml
env:
  - name: SPRING_DATASOURCE_USERNAME
    valueFrom:
      secretKeyRef:
        name: staging-rds-credentials
        key: username
  - name: SPRING_DATASOURCE_PASSWORD
    valueFrom:
      secretKeyRef:
        name: staging-rds-credentials
        key: password
  - name: SPRING_DATASOURCE_URL
    valueFrom:
      secretKeyRef:
        name: staging-rds-credentials
        key: host
  # ... additional environment variables
  - name: SPRING_REDIS_HOST
    valueFrom:
      secretKeyRef:
        name: staging-elasticache-credentials
        key: host
  - name: SPRING_REDIS_PASSWORD
    valueFrom:
      secretKeyRef:
        name: staging-elasticache-credentials
        key: password
```

Or using volume mounts for mounted credentials:

```yaml
volumeMounts:
  - name: rds-credentials
    mountPath: /etc/secrets/rds
    readOnly: true
  - name: redis-credentials
    mountPath: /etc/secrets/redis
    readOnly: true

volumes:
  - name: rds-credentials
    secret:
      secretName: staging-rds-credentials
  - name: redis-credentials
    secret:
      secretName: staging-elasticache-credentials
```

## Sync Wave Dependency Chain

```
sync-wave: -1  → core-shared-secrets-app (ExternalSecrets synced from Vault)
                     ↓
sync-wave: 0   → infra-app, core-api-gateway, core-discovery-client, 
                 edge services (all depend on shared secrets)
```

## Troubleshooting

### Secrets Not Syncing

1. **Check ClusterSecretStore**:
   ```bash
   kubectl describe clustersecretstore vault-backend -n banking-infra
   ```

2. **Check ExternalSecret Status**:
   ```bash
   kubectl get externalsecrets -n banking
   kubectl describe externalsecret staging-rds-external-secret -n banking
   ```

3. **Vault Permissions**: Ensure the Vault auth method has access to the specified paths:
   - `banking/rds`
   - `banking/redis`
   - `banking/rabbitmq`

### Pod CreateContainerConfigError

1. Verify the secret exists:
   ```bash
   kubectl get secrets -n banking | grep -E "(rds|elasticache|rabbitmq)"
   ```

2. Verify pod is referencing the correct secret names in volumeMount or env

## Adding New Shared Secrets

1. Add a new ExternalSecret block to `charts/shared-secrets/templates/external-secrets.yaml`
2. Add corresponding values to `environments/staging/shared-secrets-values.yaml`
3. Reference the new secret in service values files
4. ArgoCD will auto-sync the changes

## Production Deployment

For production, create `environments/prod/shared-secrets-values.yaml` with:
- Different Vault paths (e.g., `banking-prod/rds`)
- Different secret target names (e.g., `prod-rds-credentials`)
- Different namespace (if using separate namespace)

Then create `argocd/prod/apps/core/core-shared-secrets-app.yaml` pointing to the prod values.
