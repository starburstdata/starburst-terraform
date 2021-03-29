affinity: {}
authentication:
  google:
    clientId: null
    clientSecret: null
    hostedDomain: null
  type: none
chartsVersion: ${charts_version}
database:
  external:
    port: ${primary_db_port}
    host: ${primary_ip_address}
    databaseName: ${primary_db_mc}
    user: ${primary_db_user}
    password: ${primary_db_password}
  internal:
    databaseName: missioncontrol
    image:
      pullPolicy: IfNotPresent
      repository: library/postgres
      tag: "11.3"
    password: McPass123
    port: 5432
    resources:
      limits:
        cpu: 2
        memory: 1Gi
      requests:
        cpu: 2
        memory: 1Gi
    user: mission_control_admin
    volume:
      emptyDir: {}
  type: ${type}
debug:
  enabled: false
  port: 5005
  suspend: "y"
expose:
  clusterIp:
    name: ${expose_mc_name}
    ports:
      http:
        port: 5042
  ingress:
    annotations:
      cert-manager.io/cluster-issuer: ${secret_key_ref}
      kubernetes.io/ingress.class: nginx
    host: ${mc_service_prefix}.${dns_zone}
    path: /
    tls:
      enabled: true
      secretName: ${expose_mc_name}
  loadBalancer:
    name: ${expose_mc_name}
    ports:
      http:
        port: 5042
  type: ${service_type}
image:
  pullPolicy: IfNotPresent
  repository: ${repository}
  tag: ${charts_version}
missioncontrol:
  additionalJvmConfig: |
    -XX:+HeapDumpOnOutOfMemoryError
    -XX:+UseGCOverheadLimit
    -XX:+ExitOnOutOfMemoryError
  allowInsecureHttp: true
  memoryAllocation: 1G
nodeSelector: {}
port: 5042
prestoVersion: ${starburst_version}
registryCredentials:
  enabled: true
  registry: ${registry}
  username: ${repo_username}
  password: ${repo_password}
replicaCount: 1
tolerations: []
