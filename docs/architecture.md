# Architecture

[Back to the case study](../README.md)

The diagrams below describe the tracked configuration and its intended relationships. The original cluster was a school lab; the public manifests have not been deployed as part of this documentation update.

## Cluster Foundation

The graduation report describes installing MicroK8s on Ubuntu Server, enabling ingress and storage add-ons, and checking node and Pod status. The repository contains resources that depend on that cluster setup rather than an installer for it.

- [Platform namespaces](../k8s/infra/bootstrap/namespaces.yaml) group Argo CD, GitLab, monitoring, logging, and ingress resources. The [student app manifests](../k8s/apps/) include their own namespace definitions. These boundaries organize resources and names; they do not by themselves restrict network traffic.
- [StorageClass](../k8s/infra/storage-class.yaml) selects the MicroK8s hostpath provisioner. Stateful services such as [GitLab](../k8s/apps/gitlab/pvc.yaml) request that storage through PVCs. Node-local storage fits a lab but does not establish data replication or failover.

## GitOps Control Path

```text
Git repository and revision
  -> root Application (source path: argocd/applications)
     -> infrastructure Application -> k8s/infra, including bootstrap namespaces
     -> service and app Applications -> their respective k8s/apps paths
```

The [root Application](../argocd/root-application.yaml) points to a Git revision and a directory of [child Applications](../argocd/applications/). The [infrastructure Application](../argocd/applications/infra.yaml) reads its manifest directory recursively. The [GitLab Runner Application](../argocd/applications/gitlab-runner.yaml) points to a [Helm chart](../k8s/apps/gitlab-runner/Chart.yaml); other children reference manifest directories.

The root and these child examples target the in-cluster Kubernetes API. Their automated policies specify pruning and self-healing. Review the target repository, revision, and sync scope before enabling reconciliation in another environment. Argo CD must already be installed to process the root Application. The [Argo CD Ingress](../k8s/apps/argocd/ingress.yaml) is a separate manifest; no child Application in this snapshot points to that directory.

## HTTP Traffic Path

```text
Lab client with an application hostname
  -> allocated LAN address on ingress-lb (TCP 80)
  -> NGINX Ingress controller
  -> Ingress rule for the hostname and path
  -> application Service backend and port
  -> selected application Pod endpoint
```

This is a logical routing path. It identifies the Service used by each rule without assuming that every request traverses the Service's virtual IP.

| Resource | What the tracked YAML specifies |
| --- | --- |
| [MetalLB pool and advertisement](../k8s/infra/metallb-pool.yaml) | An `IPAddressPool` named `example-lan-pool` and an `L2Advertisement` for that pool. The address range is a placeholder. |
| [Ingress entry Service](../k8s/infra/ingress-lb.yaml) | A `LoadBalancer` Service in `ingress` requesting that pool, with a selector for the expected MicroK8s NGINX controller Pods and a TCP port 80 mapping. |
| [Example app Ingress](../k8s/apps/dexd-bazar/app/ingress.yaml) | The `public` Ingress class maps a placeholder hostname and the `/` prefix to the app Service on port 80. |
| [Example app Service](../k8s/apps/dexd-bazar/app/service.yaml) | The Service uses the default `ClusterIP` type and selects app Pods by label. |

MetalLB supplies the LAN-facing address. The controller interprets the Ingress rules and routes traffic to the selected backend. The lab pattern assumes client name resolution, a reachable address pool, and a matching controller in the Service's namespace. The tracked LoadBalancer Service does not expose port 443, even though some Ingress resources declare TLS and redirects. A working HTTPS path would need to be configured and tested separately.

## Observability Paths

- **Metrics:** The [Prometheus configuration](../k8s/apps/prometheus/configMap.yaml) defines self-scraping, discovery of annotated Pods, and an Argo CD target. The [Grafana data source](../k8s/apps/grafana/configMap.yaml) points to the Prometheus Service. A node exporter manifest is present in [infrastructure](../k8s/infra/node-exporter.yaml); its presence alone does not show that Prometheus scrapes it.
- **Logs:** The [Fluent Bit DaemonSet](../k8s/apps/fluentbit/daemonset.yaml) and its [configuration](../k8s/apps/fluentbit/configmap.yaml) describe tailing container logs and forwarding them to Elasticsearch. [Kibana](../k8s/apps/kibana/deployment.yaml) is configured to query Elasticsearch using a Secret reference. [Elasticsearch](../k8s/apps/elasticsearch/configmap.yaml) enables security, while the tracked Fluent Bit outputs do not specify authentication. Verify that integration in a rebuild before claiming working log delivery.

## Rebuild Checklist

1. Prepare a compatible Kubernetes environment with DNS, the expected Ingress controller and class, and hostpath storage provisioning. Confirm controller Pod labels and namespace against the entry Service selector.
2. Install MetalLB and its CRDs, then provide an address pool appropriate for the lab network. Configure DNS for the chosen hostnames and validate HTTP routing before adding any TLS exposure.
3. Install Argo CD, set usable repository URLs and revisions in the Application resources, and confirm that all image references are accessible. Review automated prune and self-heal settings before the first sync.
4. Provision environment-specific Secrets and certificates outside Git, including application database credentials and any runner or logging credentials needed for the chosen services.
5. Check node and Pod readiness, Service endpoints, Argo CD sync and health, and an actual client request through Ingress. Test metrics and log ingestion separately.

This is a checklist, not a tested installation sequence. The historical report documents its MicroK8s installation and lab validation in sections 3.2 to 3.5; the defense deck summarizes the design and observed state on slides 4, 7, and 9. The original source files are intentionally not published here.
