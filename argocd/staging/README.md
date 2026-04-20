# ArgoCD Staging Skeleton (GIT-01)

This directory is the canonical staging manifest layout for ArgoCD.
GIT-01 intentionally defines structure and naming only, without operational specs.

## Directory Layout

- `project/`: AppProject definitions for staging guardrails.
- `root/`: Root Application (App-of-Apps entrypoint).
- `apps/controllers/`: Child apps for platform controllers.
- `apps/infra/`: Child apps for shared infrastructure.
- `apps/core/`: Child apps for foundational services.
- `apps/edge/`: Child apps for edge and business services.

## Naming Conventions

- AppProject: `banking-staging`
- Root Application: `banking-staging-root`
- Child Application pattern: `banking-staging-<layer>-<service>`

Examples:
- `banking-staging-controllers-aws-load-balancer-controller`
- `banking-staging-infra-shared`
- `banking-staging-core-discovery-client`
- `banking-staging-edge-account-service`

## Layer Mapping

- Controllers: aws-load-balancer-controller, external-secrets-operator
- Infra: banking-infrastructure chart release
- Core: discovery-client-service, api-gateway-service
- Edge: account, bank, credit-card, invoice, log, user services

## Notes

- Sync policies, sync waves, and source/destination wiring are added in later tasks.
- Keep all ArgoCD control objects in namespace `argocd`.
- Workload destinations remain in namespace `banking-staging` unless explicitly changed.
