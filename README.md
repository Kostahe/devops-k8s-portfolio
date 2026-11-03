# DevOps Kubernetes Cluster

This repository contains a cleaned public portfolio version of a school proof-of-concept Kubernetes project. It demonstrates a GitOps-managed, self-managed Kubernetes environment with application delivery, ingress routing, MetalLB-based load balancing, monitoring, and centralized logging.

The original project was built to validate a functional Kubernetes-based environment for selected web applications in a school laboratory setting. This public version keeps the useful Kubernetes, ArgoCD, MetalLB, Ingress, monitoring, and logging manifests while replacing internal infrastructure values with placeholders.

## Technologies Used

| Technology | Purpose |
| --- | --- |
| Kubernetes | Container orchestration for applications and platform services |
| MicroK8s | Lightweight Kubernetes distribution used for the self-managed lab cluster |
| ArgoCD | GitOps synchronization and app-of-apps deployment model |
| GitLab | Self-hosted Git repository platform and CI/CD integration target |
| NGINX Ingress Controller | HTTP/HTTPS routing into cluster services |
| MetalLB | LoadBalancer support for bare-metal networking |
| Prometheus | Metrics collection |
| Grafana | Metrics visualization and dashboards |
| Elasticsearch | Log storage and indexing |
| Kibana | Log search and visualization |
| Fluent Bit | Log collection and forwarding |

## Architecture Summary

The repository follows a GitOps model. ArgoCD reads application definitions from the `argocd/` directory and synchronizes Kubernetes manifests from `k8s/` into the cluster.

High-level request flow:

```text
User -> External IP -> NGINX Ingress -> Kubernetes Service -> Pod
```

MetalLB provides external IP allocation for the self-managed Kubernetes cluster, while the ingress controller routes traffic to GitLab, ArgoCD, Grafana, Kibana, and demo applications. Prometheus and Grafana provide monitoring, and Fluent Bit forwards logs into Elasticsearch for search and visualization through Kibana.

## Repository Structure

```text
argocd/
  root-application.yaml        # ArgoCD app-of-apps root
  applications/                # ArgoCD Application resources

k8s/
  infra/                       # Cluster infrastructure manifests
  infra/bootstrap/             # Namespace bootstrap resources
  apps/                        # Platform and demo application manifests
    argocd/
    elasticsearch/
    fluentbit/
    gitlab/
    gitlab-runner/
    grafana/
    kibana/
    prometheus/
    dexd-bazar/
    innotechvision/
    parkovani/
    zlatakotva/

assets/                        # Supporting project assets
zdroje/                        # Source/reference materials
```

## My Role

My main responsibility was Kubernetes cluster setup and infrastructure integration, including networking, Ingress configuration, MetalLB setup, and support for the GitOps deployment structure. I also helped connect platform services such as monitoring and logging into the overall cluster design.

## Team Responsibilities

Group GitHub organization: [SSEMI-TRADERS](https://github.com/SSEMI-TRADERS)

- [Konstantyn Huzil](https://github.com/Kostahe) - Kubernetes cluster setup, networking, Ingress, and MetalLB integration
- [Jachym Pantoflicek](https://github.com/jasanjasanjasan) - GitLab deployment, persistent storage, and GitOps integration
- [Jakub Ryba](https://github.com/KubaCZ007) - ArgoCD configuration, app-of-apps structure, and environment management
- Tomas Mejsnar - Prometheus and Grafana monitoring setup
- [Petr Spor](https://github.com/TheWeth) - Elasticsearch, Kibana, and Fluent Bit logging setup

## Project Status

This repository is a public portfolio version of the original school project. It is intended for documentation and demonstration purposes. The manifests may require environment-specific changes before deployment.

## Security and Public Portfolio Note

This repository contains a cleaned public version of a school proof-of-concept Kubernetes project. Internal domains, IP addresses, and credentials were replaced with placeholders. The project is not intended to represent production-ready infrastructure.

## Notes

- Placeholder hostnames use the `example.local` domain.
- Placeholder Git URLs use `https://gitlab.example.local/example/devops-k8s.git`.
- MetalLB address ranges must be replaced with a real local network range before deployment.
- Secret manifests are intentionally excluded from this public repository; create environment-specific secrets outside version control.
