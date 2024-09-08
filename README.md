# CTFd Helm Chart
![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.7.3](https://img.shields.io/badge/AppVersion-3.7.3-informational?style=flat-square)

This is a Helm chart for deploying CTFd on Kubernetes. It is deploys the official [CTFd Docker image](ghcr.io/ctfd/ctfd). Supports HA and Autoscaling.

## Installation

Build helm dependencies (Redis and MariaDB) before installing the chart.

```bash
helm dependency update
```

Set the values in `values.yaml` to your desired configuration. You can also use the `--set` flag to override values during installation.

```bash
helm install ctfd . -f values.yaml --create-namespace --namespace ctfd
```

## Uninstallation
```bash
helm uninstall ctfd --namespace ctfd
```

## Features

- [x] HA and horizontal autoscaling with CPU and memory metrics
- [x] Configurable CPU/memory requests and limits
- [x] Deploys bitnami Redis, bitnami MariaDB and SeaweedFS S3 as Helm dependencies
- [X] Option to use AWS S3 or any other external S3 compatible storage as an upload provider
- [x] Option to use external Redis and MariaDB (e.g., AWS RDS, ElastiCache)
- [x] Customizable CTFd configuration
- [x] Adjustable configurations for Redis and MariaDB
- [x] Integration with external storage as upload provider (AWS S3 or SeaweedFS or any otherr S3 compatible storage)
- [x] Liveness and Readiness checks
- [x] Affinity/Toleration/nodeSelector rules
- [ ] Automatically rolls out config updates to CTFd pods (Using checksum annotation)
- [ ] Deploys self-hosted mail server for CTFd email notifications as a helm dependency
- [ ] Automated backups (CTFd export. This could be done with batch/v1 CronJob)
- [ ] Deploys postgres db as a helm dependency

## To Do

- [ ] Performance testing to verify autoscaling capabilities + e2e testing for verification
- [x] Fine tune cpu/mem requests and limits
- [ ] Chaos testing to verify HA capabilities
- [x] Add Pod Disruption budget (Added a rolling update strategy instead)
- [ ] Security testing to verify deployment security
- [x] Helm linting and testing with GitHub Actions (status badge remaining)
- [ ] Publish Helm chart to Artifact Hub
- [x] Custom NOTES.txt (post-installation message)
- [ ] Support custom metrics for autoscaling
- [x] Fancier README.md with badges and more information
- [x] Add Chart Values table to README.md

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | mariadb | 19.0.5 |
| https://charts.bitnami.com/bitnami | redis | 20.0.5 |
| https://seaweedfs.github.io/seaweedfs/helm | seaweedfs | 4.0.0 |

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
| ctfd.image.tag | string | `appVersion` | Overrides the image tag (version) |
| ctfd.imagePullSecrets | list | `[]` | Image pull secrets (use this for private repos) |
| ctfd.ingress.annotations | object | `{}` | Ingress annotations |
| ctfd.ingress.className | string | `""` | Ingress class |
| ctfd.ingress.enabled | bool | `false` | Enables ingress |
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
| ctfd.resources.limits | object | `{"cpu":"2","memory":"2Gi"}` | CTFd pod CPU limit |
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
| mariadb.architecture | string | `"standalone"` | MariaDB Architecture (`standalone`, `replication`) |
| mariadb.auth.database | string | `"ctfd"` |  |
| mariadb.auth.password | string | `"ctfd"` |  |
| mariadb.auth.rootPassword | string | `"ctfd"` |  |
| mariadb.auth.username | string | `"ctfd"` |  |
| mariadb.enabled | bool | `true` | Deploys bitnami's mariadb (set to false if you want to use an external database) |
| mariadb.external | object | ignored | External database connection details. Takes effect if `mariadb.enabled` is set to false |
| mariadb.metrics.enabled | bool | `true` |  |
| mariadb.primary.extraFlags | string | Check `values.yaml`. Used by official CTFd `docker-compose.yml` | MariaDB primary entrypoint extra flags |
| mariadb.primary.persistence.enabled | bool | `true` |  |
| mariadb.primary.persistence.size | string | `"2Gi"` |  |
| mariadb.primary.resourcePreset | string | `"small"` |  |
| mariadb.secondary.extraFlags | string | Check `values.yaml`. Used by official CTFd `docker-compose.yml` | MariaDB primary entrypoint extra flags |
| mariadb.secondary.persistence.enabled | bool | `true` |  |
| mariadb.secondary.persistence.size | string | `"2Gi"` |  |
| mariadb.secondary.replicaCount | int | `1` |  |
| mariadb.secondary.resourcePreset | string | `"small"` |  |
| mariadb.volumePermissions.enabled | bool | `true` |  |
| redis.auth.enabled | bool | `false` |  |
| redis.enabled | bool | `true` | Deploys bitnami's redis (set to false if you want to use an external cache) |
| redis.external | object | ignored | External redis cache connection details. Takes effect if `redis.enabled` is set to false |
| redis.master.count | int | `1` |  |
| redis.master.persistence.enabled | bool | `false` |  |
| redis.master.resourcesPreset | string | `"micro"` |  |
| redis.metrics.enabled | bool | `true` |  |
| redis.replica.autoscaling.enabled | bool | `true` |  |
| redis.replica.autoscaling.targetCPU | string | `"80"` |  |
| redis.replica.persistence.enabled | bool | `false` |  |
| redis.replica.resourcesPreset | string | `"micro"` |  |
| redis.sysctl.enabled | bool | `true` |  |
| redis.volumePermissions.enabled | bool | `true` |  |
| seaweedfs.enabled | bool | `true` | Deploys seaweedfs (set to false if you want to use an bucket) |
| seaweedfs.filer.data.size | string | `"5Gi"` | seaweedfs-filer storage size |
| seaweedfs.filer.data.type | string | `"persistentVolumeClaim"` | seaweedfs-filer data storage type |
| seaweedfs.filer.enablePVC | bool | `true` | seaweedfs-filer enable PVC for data persistence |
| seaweedfs.filer.replicas | int | `3` | seaweedfs-filer replicas |
| seaweedfs.filer.s3.createBuckets | list | `[{"name":"ctfd-bucket"}]` | seaweedfs-s3 create bucket upon deploying |
| seaweedfs.filer.s3.enableAuth | bool | `false` | seaweedfs-s3 enable authentication (no need since seaweed is private to the cluster) |
| seaweedfs.filer.s3.enabled | bool | `true` | seaweedfs-s3 enable. This enables S3 API (Should be left to `true`) |
| seaweedfs.filer.storage | string | `"5Gi"` | seaweedfs-filer PVC storage size |
| seaweedfs.master.data.size | string | `"5Gi"` | seaweedfs storage size |
| seaweedfs.master.data.type | string | `"persistentVolumeClaim"` | seaweedfs data storage type |
| seaweedfs.master.replicas | int | `3` | seaweedfs-master replicas |
| seaweedfs.volume.replicas | int | `3` | seaweedfs-volume replicas |

## NOTES

- CTFd `SECRET_KEY` is automatically generated during installation. You can find it in the secret `ReleaseName-ctfd-secret-key`. This secret is added as environment variable in all CTFd pods.
- Redis in this chart uses single master with multiple workers.
- This chart deploys SeaweedFS S3 as an upload provider. You can use AWS S3 or any other external S3 compatible storage as an upload provider. Just set `seaweedfs.enabled` to `false` and configure the external S3 provider in `uploadprovider.s3`.

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
