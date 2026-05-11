# Support Infrastructure Pipeline

This folder contains a Jenkins pipeline for deploying shared Kubernetes support infrastructure on EKS.

## Scope

The pipeline deploys only shared support components already used in this repository:

- `infrastructure/support/charts/mongodb`
- `infrastructure/support/charts/rabbitmq`
- `infrastructure/support/charts/qdrant`
- Istio control plane and ingress (`istio/base`, `istio/istiod`, `istio/gateway`)
- `infrastructure/support/charts/always-open-istio`
- `infrastructure/support/manifests/istio`

Secrets are intentionally **not** managed by this pipeline.

## Jenkinsfile

Use `infrastructure/support/Jenkinsfile`.

### Parameters

- `ACTION`: `plan`, `apply`, or `destroy`
- `ENVIRONMENT`: `dev`, `staging`, `production`
- `AWS_REGION`: EKS region
- `CLUSTER_NAME`: EKS cluster name
- `AWS_CREDENTIALS_ID`: Jenkins AWS credentials id
- `NAMESPACE_INFRA`: namespace for MongoDB/RabbitMQ/Qdrant
- `NAMESPACE_APP`: namespace for app-level Istio resources
- `NAMESPACE_ISTIO`: namespace for Istio control plane
- `ISTIO_VERSION`: Istio Helm version
- `DOMAIN_NAME`: domain passed to `always-open-istio` chart
- `REQUIRE_MANUAL_APPROVAL`: if true, pause before `apply`/`destroy`

### Destroy guard

`destroy` is blocked when `ENVIRONMENT` is `production` (or `prod`).

## Notes

- This pipeline is intentionally separated from `infrastructure/Jenkinsfile` (Terraform/EKS provisioning).
- Existing `envoy` manifests can be used as reference for Istio routes/policies; this pipeline deploys Istio resources using charts/manifests stored under `infrastructure/support`.
