# Kubernetes Lab: Cluster Setup and Service Networking

A team graduation project (2025/2026) that tested whether a self-managed MicroK8s cluster could host several student web applications alongside GitOps, monitoring, and logging services. The project ran as a school lab proof of concept.

## My Contribution

I'm [Konstantyn Huzil](https://github.com/Kostahe). I set up the cluster and integrated the infrastructure that the team's services ran on.

- Installed MicroK8s on Ubuntu Server, enabled the ingress and storage add-ons, and checked node and system Pod readiness.
- Configured service networking: internal Kubernetes Services, host-based Ingress, and a shared LoadBalancer Service backed by a MetalLB address pool.
- Organized platform components and applications into namespaces and prepared the cluster for the team's GitLab, GitOps, monitoring, and logging work.
- Checked deployment state in Argo CD and verified that selected services were reachable through Ingress during the lab validation.

Start with the [LoadBalancer Service](k8s/infra/ingress-lb.yaml), [MetalLB configuration](k8s/infra/metallb-pool.yaml), and [namespace definitions](k8s/infra/bootstrap/namespaces.yaml) to see the infrastructure in the repository.

## Architecture

```text
Git configuration -> Argo CD root Application -> child Applications -> MicroK8s resources
Lab client -> MetalLB-backed LoadBalancer Service -> NGINX Ingress -> app Service -> Pod
```

| Layer | Tools and purpose |
| --- | --- |
| Runtime | MicroK8s runs Kubernetes workloads; a hostpath StorageClass supports lab persistence. |
| Networking | MetalLB allocates an address for the entry Service. NGINX Ingress routes HTTP requests by hostname and path. |
| Delivery | Argo CD reconciles Git configuration through an app-of-apps layout. GitLab and a GitLab Runner Helm chart represent the repository and CI/CD components. |
| Monitoring | Prometheus is configured to scrape metrics; Grafana uses it as a data source. |
| Logging | Fluent Bit is configured to collect container logs and send them to Elasticsearch for inspection in Kibana. |

See the [architecture walkthrough](docs/architecture.md) for the actual resource relationships, metrics and log paths, and setup requirements.

## Historical Validation

The graduation report's validation section and defense presentation document a lab session in which selected applications showed `Synced` and `Healthy` in Argo CD. The report also records successful access to selected services through Ingress. These observations describe the original lab, not a live deployment of this repository. They do not establish uptime, failover, or the success of every service integration.

## Reproduction and Limits

The public snapshot is a reference for a lab rebuild. It assumes a compatible MicroK8s environment, an Ingress controller, MetalLB, Argo CD, storage provisioning, and access to the referenced container images. Replace the example Git URLs, hostnames, and MetalLB address range. Supply the required Kubernetes Secrets separately. The tracked entry Service exposes port 80; TLS settings in individual Ingress resources do not establish an external HTTPS listener.

The [lessons and trade-offs](docs/lessons-learned.md) distinguish what the sources show from what a new deployment would still need to verify.

## Repository Guide

| Path | Contents |
| --- | --- |
| [`argocd/`](argocd/) | Root Application and child Application definitions |
| [`k8s/infra/`](k8s/infra/) | Namespaces, LoadBalancer, MetalLB, storage, and node exporter configuration |
| [`k8s/apps/`](k8s/apps/) | Platform and student application manifests, including the GitLab Runner chart |
| [`assets/`](assets/) and [`zdroje/`](zdroje/) | Existing GitLab branding and project reference links |
| [`docs/`](docs/) | Architecture and lessons from the portfolio review |

## Team Credit

The original project was built by [SSEMI-TRADERS](https://github.com/SSEMI-TRADERS). See the [upstream public snapshot](https://github.com/SSEMI-TRADERS/devops-k8s-portfolio).

- [Konstantyn Huzil](https://github.com/Kostahe): MicroK8s cluster setup, networking, Ingress, MetalLB, and infrastructure integration.
- [Jachym Pantoflicek](https://github.com/jasanjasanjasan): GitLab deployment, persistent storage, and GitOps integration.
- [Jakub Ryba](https://github.com/KubaCZ007): Argo CD configuration, app-of-apps structure, and environment management.
- Tomas Mejsnar: Prometheus and Grafana monitoring.
- [Petr Spor](https://github.com/TheWeth): Elasticsearch, Kibana, and Fluent Bit logging.

## Security and Portfolio Scope

This repository contains a cleaned public version of a school proof-of-concept Kubernetes project. Internal domains, IP addresses, and credentials were replaced with placeholders. The project is not intended to represent production-ready infrastructure.

This case study and its technical documentation were written after graduation. The original thesis, defense deck, and screenshots are excluded. The case study does not change the deployment manifests.
