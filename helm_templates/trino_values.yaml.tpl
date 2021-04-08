registryCredentials:
  enabled: true
  registry: ${registry}
  username: ${repo_username}
  password: ${repo_password}

starburstPlatformLicense: "starburst"

expose:
  type: ${service_type} #"loadBalancer"
  loadBalancer:
    name: ${expose_sb_name}
    ports:
      http:
        port: 8080
  ingress:
    serviceName: ${expose_sb_name}
    servicePort: 8080
    host: ${starburst_service_prefix}.${dns_zone}
    path: "/"
    pathType: Prefix
    tls:
      enabled: true
      secretName: tls-secret-starburst
    annotations:
      kubernetes.io/ingress.class: nginx
      cert-manager.io/cluster-issuer: ${secret_key_ref}

userDatabase:
  enabled: false

coordinator:
  resources:
    requests:
      memory: "10Gi"
      cpu: 1
    limits:
      memory: "10Gi"
      cpu: 1
  etcFiles:
    properties:
      config.properties: |
        coordinator=true
        node-scheduler.include-coordinator=false
        http-server.http.port=8080
        discovery-server.enabled=true
        discovery.uri=http://localhost:8080
        usage-metrics.cluster-usage-resource.enabled=true
        http-server.authentication.allow-insecure-over-http=true
        web-ui.enabled=true
        http-server.process-forwarded=true
      access-control.properties: |
        access-control.name=ranger
        ranger.authentication-type=BASIC
        ranger.policy-rest-url=http://${expose_ranger_name}:6080
        ranger.service-name=starburst-enterprise
        ranger.presto-plugin-username=${admin_user}
        ranger.presto-plugin-password=${admin_pass}
        ranger.policy-refresh-interval=10s
  nodeSelector:
    starburstpool: ${primary_node_pool}

worker:
  etcFiles:
    properties:
      access-control.properties: |
        access-control.name=ranger
        ranger.authentication-type=BASIC
        ranger.policy-rest-url=http://${expose_ranger_name}:6080
        ranger.service-name=starburst-enterprise
        ranger.presto-plugin-username=${admin_user}
        ranger.presto-plugin-password=${admin_pass}
        ranger.policy-refresh-interval=10s
  autoscaling:
    enabled: true
    minReplicas: ${worker_autoscaling_min_size}
    maxReplicas: ${worker_autoscaling_max_size}
  resources:
    requests:
      memory: "10Gi"
      cpu: 1
    limits:
      memory: "10Gi"
      cpu: 1
  nodeSelector:
    starburstpool: ${worker_node_pool}

catalogs:
  tpcds: |
    connector.name=tpcds
  jmx: |
    connector.name=jmx
  hive: |
    connector.name=hive-hadoop2
    hive.allow-drop-table=true
    hive.metastore.uri=${hive_service_url}

