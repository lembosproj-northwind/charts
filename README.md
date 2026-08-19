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

## How Lembos resolves these

From **git**, not from a registry. A seeded `BlueprintVersion` points at this repository, the chart's own
directory, and a tag:

```
location   https://github.com/lembosproj-northwind/charts
path       helm-web-service
reference  helm-web-service/v2.4.0
```

The tag carries the chart name because one repository holds four of them — a bare `v2.4.0` could not say
which chart it versioned. **Publishing a new chart version means cutting that tag**, or the blueprint
version pointing at it resolves to nothing.

A real platform would keep charts in an OCI registry, and that is where these should end up:

```shell
helm package helm-web-service && helm push helm-web-service-2.4.0.tgz oci://ghcr.io/lembosproj-northwind/charts
```

That move is deliberate and not yet made. Nothing publishes these charts to a registry, so an `oci://`
coordinate in the seed would be a promise about infrastructure that does not exist — and the failure would
arrive during a deployment rather than while somebody was reading the catalog.
