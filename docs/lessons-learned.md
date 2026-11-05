# Lessons and Trade-offs

[Back to the case study](../README.md) | [Architecture](architecture.md)

These lessons come from the original lab report and the configuration in this repository. They distinguish design trade-offs from results observed during the school project.

## A Shared Entry Point Simplifies Lab Routing

The [LoadBalancer Service](../k8s/infra/ingress-lb.yaml) and [MetalLB pool](../k8s/infra/metallb-pool.yaml) provide one address allocation path for multiple Ingress rules. Most application backends can remain internal Services. This avoids allocating a separate LAN-facing address per application, but creates dependencies on the address pool, DNS, and the expected controller. A route can fail at any of those boundaries even while the app Pods are ready.

## Bootstrap Still Matters With GitOps

The [root Application](../argocd/root-application.yaml) and [infrastructure child](../argocd/applications/infra.yaml) make the desired configuration reviewable in Git. The design still needs a working cluster, installed controllers, repository access, and environment-specific Secrets. Automated pruning and self-healing make the selected source and scope important. A new environment should establish those prerequisites before reconciliation.

## Lab Storage Trades Portability for Simplicity

The [hostpath StorageClass](../k8s/infra/storage-class.yaml) keeps persistent storage close to the workload and relies on the MicroK8s provisioner. It fits a proof of concept, but the manifests do not show replicated volumes or a backup and recovery plan. Verify data retention and the reclaim policy before using it with data that must survive node loss or claim deletion.

## Deployment State and User Access Are Separate Checks

The graduation report's validation section and defense slide 9 show that selected applications reached `Synced` and `Healthy` during the lab. The report also describes checking access through Ingress. Those are complementary observations: reconciliation status alone does not verify DNS, TLS, an application response, or the full metrics and logging paths. The snapshot preserves configuration, not an uptime record.

## What Still Needs Confirmation

- Which endpoints and protocols were exercised in the lab? The report describes selected reachable services, but the public LoadBalancer configuration only proves that a port 80 mapping is declared.
- Was authenticated Fluent Bit delivery verified separately? The tracked configurations show the intended log path and an authentication gap to resolve for a rebuild.
- What MicroK8s release was installed? The report includes an example channel, which is not evidence of the version actually used.

## Publishing Lab Evidence

The original report, presentation, and screenshots are private reference material. Text diagrams in the case study were recreated from the manifests. Before sharing any future image, review the complete frame for internal URLs, IP addresses, credentials, identity details, and timestamps that reveal internal activity. Confirm permission to reuse logos and other third-party material, then have the project owner approve the final crop or redaction.
