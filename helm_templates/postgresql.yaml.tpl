audit:
  clientMinMessages: error
  logConnections: false
  logDisconnections: false
  logHostname: false
  logLinePrefix: ""
  logTimezone: ""
  pgAuditLog: ""
  pgAuditLogCatalog: "off"
common:
  exampleValue: common-chart
  global:
    postgresql: {}
commonAnnotations: {}
containerSecurityContext:
  enabled: true
  runAsUser: 1001
customLivenessProbe: {}
customReadinessProbe: {}
customStartupProbe: {}
extraDeploy: []
extraEnv: []
fullnameOverride: ${expose_postgres_name}
global:
  postgresql: {}
image:
  debug: false
  pullPolicy: IfNotPresent
  registry: docker.io
  repository: bitnami/postgresql
  tag: 13
ldap:
  baseDN: ""
  bindDN: ""
  enabled: false
  port: ""
  prefix: ""
  scheme: ""
  search_attr: ""
  search_filter: ""
  server: ""
  suffix: ""
  tls: {}
  url: ""
livenessProbe:
  enabled: true
  failureThreshold: 6
  initialDelaySeconds: 30
  periodSeconds: 10
  successThreshold: 1
  timeoutSeconds: 5
metrics:
  enabled: false
  extraEnvVars: {}
  image:
    pullPolicy: IfNotPresent
    registry: docker.io
    repository: bitnami/postgres-exporter
    tag: 0.8.0-debian-10-r354
  livenessProbe:
    enabled: true
    failureThreshold: 6
    initialDelaySeconds: 5
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 5
  prometheusRule:
    additionalLabels: {}
    enabled: false
    namespace: ""
    rules: []
  readinessProbe:
    enabled: true
    failureThreshold: 6
    initialDelaySeconds: 5
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 5
  securityContext:
    enabled: false
    runAsUser: 1001
  service:
    annotations:
      prometheus.io/port: "9187"
      prometheus.io/scrape: "true"
    type: ClusterIP
  serviceMonitor:
    additionalLabels: {}
    enabled: false
networkPolicy:
  allowExternal: true
  enabled: false
  explicitNamespacesSelector: {}
persistence:
  accessModes:
  - ReadWriteOnce
  annotations: {}
  enabled: true
  mountPath: /bitnami/postgresql
  selector: {}
  size: 8Gi
  subPath: ""
postgresqlDataDir: /bitnami/postgresql/data
postgresqlDatabase: postgres
postgresqlPassword: ${primary_db_password}
postgresqlSharedPreloadLibraries: pgaudit
postgresqlUsername: ${primary_db_user}
primary:
  affinity: {}
  annotations: {}
  extraInitContainers: []
  extraVolumeMounts: []
  extraVolumes: []
  labels: {}
  nodeAffinityPreset:
    key: ""
    type: ""
    values: []
  nodeSelector: {}
  podAffinityPreset: ""
  podAnnotations: {}
  podAntiAffinityPreset: soft
  podLabels: {}
  priorityClassName: ""
  service: {}
  sidecars: []
  tolerations: []
primaryAsStandBy:
  enabled: false
psp:
  create: false
rbac:
  create: false
readReplicas:
  affinity: {}
  annotations: {}
  extraInitContainers: []
  extraVolumeMounts: []
  extraVolumes: []
  labels: {}
  nodeAffinityPreset:
    key: ""
    type: ""
    values: []
  nodeSelector: {}
  persistence:
    enabled: true
  podAffinityPreset: ""
  podAnnotations: {}
  podAntiAffinityPreset: soft
  podLabels: {}
  priorityClassName: ""
  resources: {}
  service: {}
  sidecars: []
  tolerations: []
readinessProbe:
  enabled: true
  failureThreshold: 6
  initialDelaySeconds: 5
  periodSeconds: 10
  successThreshold: 1
  timeoutSeconds: 5
replication:
  applicationName: my_application
  enabled: false
  numSynchronousReplicas: 0
  password: repl_password
  readReplicas: 1
  synchronousCommit: "off"
  user: repl_user
resources:
  requests:
    cpu: 250m
    memory: 256Mi
securityContext:
  enabled: true
  fsGroup: 1001
service:
  annotations: {}
  port: 5432
  type: LoadBalancer
serviceAccount:
  enabled: false
shmVolume:
  chmod:
    enabled: true
  enabled: true
startupProbe:
  enabled: false
  failureThreshold: 10
  initialDelaySeconds: 30
  periodSeconds: 15
  successThreshold: 1
  timeoutSeconds: 5
tls:
  certFilename: ""
  certKeyFilename: ""
  certificatesSecret: ""
  enabled: false
  preferServerCiphers: true
updateStrategy:
  type: RollingUpdate
volumePermissions:
  enabled: false
  image:
    pullPolicy: Always
    registry: docker.io
    repository: bitnami/minideb
    tag: buster
  securityContext:
    runAsUser: 0
