# CTFd Helm Chart
![Version: 0.3.0](https://img.shields.io/badge/Version-0.3.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)
[![Lint and Server-side Dryrun Chart](https://github.com/ScribblerCoder/CTFd-Helm/actions/workflows/helm-lint-test.yaml/badge.svg)](https://github.com/ScribblerCoder/CTFd-Helm/actions/workflows/helm-lint-test.yaml)

This is a Helm chart for deploying CTFd on Kubernetes. It deploys the official [CTFd Docker image](ghcr.io/ctfd/ctfd). HA and Autoscaling + MariaDB + Redis + S3 Storage. Also supports using external MariaDB/Redis/S3.

## Add the helm repo
```bash
helm repo add ctfd https://scribblercoder.github.io/CTFd-Helm
```
## Install
```bash
helm install ctfd ctfd/ctfd
# OR
helm install ctfd ctfd/ctfd -f values.yaml
```

## Install from source

Build helm dependencies (MariaDB/Redis/Minio) before installing the chart.

```bash
helm dependency update
```

Set the values in `values.yaml` to your desired configuration. Then install

```bash
helm install release-name . -f values.yaml --create-namespace --namespace ctfd
```

## Uninstall
```bash
helm uninstall release-name --namespace ctfd
```

## Info

- CTFd `SECRET_KEY` is automatically generated during installation/upgrade. You can find it in the secret `release-name-ctfd-secret-key`. This secret is injected as environment variable in all CTFd pods.
- Redis in this chart uses single master with multiple workers.
- This chart deploys Minio S3 bucket as an uploadprovider. You can use AWS S3 or any other external S3 compatible storage as an upload provider. Just set `minio.enabled` to `false` and configure the external S3 provider in `ctfd.uploadprovider.s3`.
- This chart intentionally refrains from supporting `filesystem` uploadprovider. This needs `ReadWriteMany` PVCs which are expensive in cloud providers and not recommended for production use. S3 is fast and cheap.

## Values examples

### Deploy Bitnami MariaDB/Redis and Minio
```yaml
ctfd:
  image:
    tag: "latest"
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10
mariadb-galera:
  enabled: true
  persistence:
    enabled: true
    size: 2Gi
redis:
  enabled: true
minio:
  enabled: true
  persistence:
    size: 10Gi
```

### Configure your own external DB/Redis/S3
```yaml
ctfd:
  image:
    tag: "latest"
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10
  uploadprovider:
    s3:
      bucket: ""
      endpoint_url: ""
      secret_access_key: ""
      access_key_id: ""
mariadb-galera:
  enabled: false
  external:
    port: 3306
    host: ""
    username: ""
    password: ""
    database: ""
redis:
  enabled: false
  external:
    port: 6379
    host: ""
    username: ""
    password: ""
minio:
  enabled: false
```

### Disable CTFd autoscaling
```yaml
ctfd:
  image:
    tag: "latest"
  replicas: 2
  autoscaling:
    enabled: false
```

## Features

- [x] HA and horizontal autoscaling with CPU and memory metrics
- [x] Configurable CPU/memory requests and limits
- [x] Deploys bitnami Redis, bitnami MariaDB-Galera and ~~SeaweedFS S3~~ (REPLACED WITH MINIO) as Helm dependencies
- [X] Option to use AWS S3 or any other external S3 compatible storage as an upload provider
- [x] Option to use external Redis and MariaDB (e.g., AWS RDS, ElastiCache)
- [x] Customizable CTFd configuration
- [x] Adjustable configurations for Redis and MariaDB-Galera
- [x] Integration with external storage as upload provider (AWS S3 or Minio or any S3 compatible storage)
- [x] Liveness and Readiness checks
- [x] Affinity/Toleration/nodeSelector rules
- [x] Automatically rolls out config updates to CTFd pods (Using checksum annotation)
- [ ] Deploys self-hosted mail server for CTFd email notifications as a helm dependency
- [ ] Automated backups (CTFd export. This could be done with batch/v1 CronJob)
- [ ] Deploys postgres db as a helm dependency (ctfd.io doesn't actively support it so this is a low priority)
- [ ] Support for custom CTFd themes/plugin (using initContainers? this is WIP)

## To Do

- [ ] Performance testing to verify autoscaling capabilities + e2e testing for verification
- [x] Fine tune cpu/mem requests and limits
- [ ] Chaos testing to verify HA capabilities
- [x] Add Pod Disruption budget and rolling strategy
- [ ] Security testing to verify deployment security
- [x] Helm linting and testing with GitHub Actions
- [ ] Publish Helm chart to Artifact Hub or to Github Pages
- [x] Custom NOTES.txt (post-installation message)
- [ ] Support custom metrics for autoscaling
- [x] README.md with badges and detailed information
- [x] Add Chart Values table to README.md
- [ ] Support custom CTFd themes/plugin

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | mariadb-galera | 14.0.12 |
| https://charts.bitnami.com/bitnami | redis | 20.0.5 |
| https://charts.min.io/ | minio(minio) | 5.4.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ctfd.affinity | object | `{}` | CTFd affinity |
| ctfd.autoscaling.enabled | bool | `true` | Enables HPA autoscaling |
| ctfd.autoscaling.maxReplicas | int | `10` | Autoscaling max replicas |
| ctfd.autoscaling.minReplicas | int | `2` | Autoscaling min replicas |
| ctfd.autoscaling.targetCPUUtilizationPercentage | int | `80` | Autoscaling target CPU utilization percentage |
| ctfd.autoscaling.targetMemoryUtilizationPercentage | int | `80` | Autoscaling target memory utilization percentage |
| ctfd.fullnameOverride | string | `""` | Chart fullname override |
| ctfd.image.pullPolicy | string | `"IfNotPresent"` | image pull policy. One of Always, Never, IfNotPresent |
| ctfd.image.repository | string | `"ghcr.io/ctfd/ctfd"` | repository link to the CTFd docker image |
| ctfd.image.tag | string | `latest` | CTFd image tag (check https://github.com/CTFd/CTFd/pkgs/container/ctfd) |
| ctfd.imagePullSecrets | list | `[]` | Image pull secrets (use this for private repos) |
| ctfd.ingress.annotations | object | `{"nginx.ingress.kubernetes.io/proxy-body-size":"2G"}` | Ingress annotations |
| ctfd.ingress.annotations."nginx.ingress.kubernetes.io/proxy-body-size" | string | `"2G"` | Max body size for uploads (Check CTFd github repository's nginx configurations) |
| ctfd.ingress.className | string | `""` | Ingress class |
| ctfd.ingress.enabled | bool | `true` | Enables ingress |
| ctfd.initContainers | list | `[]` |  |
| ctfd.livenessProbe | object | Check `values.yaml` | CTFd readiness probe |
| ctfd.nameOverride | string | `""` | Chart name override |
| ctfd.nodeSelector | object | `{}` | CTFd node selector |
| ctfd.pdb.enabled | bool | `true` | Deploy a [PodDisruptionBudget] for the application controller |
| ctfd.pdb.maxUnavailable | string | `"50%"` | Number of pods that are unavailable after eviction as number or percentage (eg.: 50%). # Has higher precedence over `controller.pdb.minAvailable` |
| ctfd.pdb.minAvailable | string | `""` (defaults to 0 if not specified) | Number of pods that are available after eviction as number or percentage (eg.: 50%) |
| ctfd.podAnnotations | object | `{}` | CTFd pod annotations |
| ctfd.podLabels | object | `{}` | CTFd pod labels |
| ctfd.podSecurityContext | object | `{}` | CTFd pod security context |
| ctfd.readinessProbe | object | Check `values.yaml` | CTFd readiness probe |
| ctfd.replicaCount | int | `2` | CTFd replica count (If autoscaling is enabled, this value is ignored) |
| ctfd.resources.limits.cpu | string | `"2"` | CTFd pod CPU limit |
| ctfd.resources.limits.memory | string | `"2Gi"` | CTFd pod memory limit |
| ctfd.resources.requests.cpu | string | `"1"` | CTFd pod CPU request |
| ctfd.resources.requests.memory | string | `"1Gi"` | CTFd pod memory request |
| ctfd.securityContext.runAsNonRoot | bool | `true` |  |
| ctfd.securityContext.runAsUser | int | `1001` |  |
| ctfd.serviceAccount.annotations | object | `{}` | CTFd service account annotations |
| ctfd.serviceAccount.automount | bool | `true` | CTFd service account mount API credentials |
| ctfd.serviceAccount.create | bool | `true` | creates a CTFd service account |
| ctfd.serviceAccount.name | string | `""` | CTFd service account name |
| ctfd.tolerations | list | `[]` | CTFd tolerations |
| ctfd.updateStrategy.maxSurge | int | `2` | CTFd update strategy rolling update max surge (extra pods during rolling update) |
| ctfd.updateStrategy.maxUnavailable | string | `"25%"` | CTFd update strategy rolling update max unavailable pods count |
| ctfd.uploadprovider.s3.access_key_id | string | `""` | AWS S3 bucket secret key id |
| ctfd.uploadprovider.s3.bucket | string | `""` | AWS S3 bucket name |
| ctfd.uploadprovider.s3.endpoint_url | string | `""` | AWS S3 bucket region |
| ctfd.uploadprovider.s3.secret_access_key | string | `""` | AWS S3 bucket access key |
| ctfd.volumeMounts | list | `[]` | CTFd volumeMounts |
| ctfd.volumes | list | `[]` | CTFd volumes |
| extraObjects | list | `[]` | Made for deploying custom manifests with this helm chart |
| mariadb-galera.db.name | string | `"ctfd"` | ctfd database name |
| mariadb-galera.db.password | string | `"ctfd"` | ctfd database password |
| mariadb-galera.db.user | string | `"ctfd"` | ctfd database user |
| mariadb-galera.enabled | bool | `true` | Deploys bitnami's mariadb-galera (set to false if you want to use an external database) |
| mariadb-galera.external | object | ignored | External database connection details. Takes effect if `mariadb.enabled` is set to false |
| mariadb-galera.extraFlags | string | Check `values.yaml`. Used by official CTFd `docker-compose.yml` | MariaDB primary entrypoint extra flags |
| mariadb-galera.galera | object | `{"mariabackup":{"password":"ctfd"}}` | backup user (This is required by the subchart to do helm upgrades) |
| mariadb-galera.galera.mariabackup.password | string | `"ctfd"` | backup user (This is required by the subchart to do helm upgrades) |
| mariadb-galera.metrics.enabled | bool | `false` |  |
| mariadb-galera.persistence.enabled | bool | `true` |  |
| mariadb-galera.persistence.size | string | `"2Gi"` | PVC size |
| mariadb-galera.replicaCount | int | `3` | Number of primary nodes replicas |
| mariadb-galera.resourcesPreset | string | `"large"` | request and limits preset (check bitnami's mariadb-galera chart for details) |
| mariadb-galera.rootUser.password | string | `"ctfd"` | root user |
| minio.buckets[0] | object | `{"name":"ctfd-bucket","policy":"download","purge":false}` | Default bucket to be used by CTFd `download` policy means this bucket is readonly for anonymous access (competitors) |
| minio.drivesPerNode | int | `1` | Minio number of drives per replica/node |
| minio.enabled | bool | `true` | Deploys Minio (set to false if you want to use an external S3 bucket) |
| minio.ingress | object | `{"annotations":{"nginx.ingress.kubernetes.io/proxy-body-size":"0"},"enabled":true,"hosts":["minio.example.com"]}` | Ingress configurations of minio (Used by both CTFd and competitiors) |
| minio.ingress.annotations."nginx.ingress.kubernetes.io/proxy-body-size" | string | `"0"` | Max Body size `0 -> unlimited` (if you are using another ingress controller then look for the equivalent annotation)  |
| minio.persistence | object | `{"size":"10Gi"}` | Minio PVC size (change according to your needs) |
| minio.replicas | int | `3` | Minio number of replicas |
| minio.resources.requests.memory | string | `"2Gi"` |  |
| redis.auth.enabled | bool | `false` |  |
| redis.enabled | bool | `true` | Deploys bitnami's redis (set to false if you want to use an external cache) |
| redis.external | object | ignored | External redis cache connection details. Takes effect if `redis.enabled` is set to false |
| redis.master.count | int | `1` |  |
| redis.master.persistence.enabled | bool | `false` |  |
| redis.master.resourcesPreset | string | `"micro"` | Check Bintami's documentation |
| redis.metrics.enabled | bool | `true` |  |
| redis.replica.autoscaling.enabled | bool | `true` |  |
| redis.replica.autoscaling.targetCPU | string | `"80"` |  |
| redis.replica.persistence.enabled | bool | `false` |  |
| redis.replica.resourcesPreset | string | `"micro"` | Check Bintami's documentation |
| redis.sysctl.enabled | bool | `true` |  |
| redis.volumePermissions.enabled | bool | `true` |  |

Autogenerated from chart metadata using [helm-docs](https://github.com/norwoodj/helm-docs)
