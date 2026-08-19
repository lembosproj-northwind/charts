# Northwind Charts

The Helm blueprints the Lembos sample organisation is built from. Four charts, matching the four
`BlueprintProvisionerType.Helm` entries the Orchestrator seeds:

| Chart | Blueprint | Version | Type |
| --- | --- | --- | --- |
| `helm-web-service` | `platform/helm-web-service` | 2.4.0 | Component |
| `helm-worker` | `platform/helm-worker` | 1.9.0 | Component |
| `helm-cron-job` | `platform/helm-cron-job` | 1.2.0 | Component |
| `kubernetes-namespace` | `platform/kubernetes-namespace` | 1.3.0 | Environment |

**Chart versions are load-bearing.** They are the `VersionTag` the seeded BlueprintVersion pins, and the
coordinate a deployment resolves. Changing one here without changing the seed makes a published version
unresolvable — which is a real state the platform models, but not one to reach by accident.

## The values contract

The three component charts take the **same** values shape, because Lembos renders it from a
`ComponentSpecVersion` and does not know which chart it is feeding:

```yaml
lembos:                 # who this is, resolved by the deployment workflow
  component: ordering/order-api
  environment: northwind/prod
  stamp: eu-west
  specVersion: "1.4.0"
image:
  repository: ghcr.io/lembosproj-northwind/apps/web-service
  digest: ""            # pinned artifact digest; wins over tag when set
  tag: latest
replicas: 2             # ComponentSpecVersion.Replicas
ports:                  # ComponentSpecVersion.Ports
  - { name: http, port: 8080, protocol: http, isPublic: true }
resourceBindings:       # one per ResourceNeed, keyed by its handle
  ordersDb:
    secretRef: northwind/prod/ordering/orders-db
config: {}              # the merged ConfigSet, as environment variables
sizeClass: small        # drives requests/limits
```

`resourceBindings` carries a **secret reference, never a secret value** — the path a workload resolves at
start-up. A chart that took a password as a value would put it in the release's stored manifest.

## Publishing

Charts publish as OCI artifacts to `ghcr.io/lembosproj-northwind/charts/{name}:{version}`, which is the
coordinate `SampleDataSeeder.ArtifactSourceFor` synthesises.

```shell
helm package helm-web-service && helm push helm-web-service-2.4.0.tgz oci://ghcr.io/lembosproj-northwind/charts
```
