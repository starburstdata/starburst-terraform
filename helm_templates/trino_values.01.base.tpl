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

coordinator:
  resources:
    requests:
      memory: "12Gi"
      cpu: 2
    limits:
      memory: "12Gi"
      cpu: 2
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
  nodeSelector:
    starburstpool: ${primary_node_pool}

worker:
  etcFiles:
    properties:
  autoscaling:
    enabled: true
    minReplicas: ${worker_autoscaling_min_size}
    maxReplicas: ${worker_autoscaling_max_size}
  deploymentTerminationGracePeriodSeconds: 60 # default is 300; it is actually how long the graceful shutdown waits after it receives the SIGTERM
  starburstWorkerShutdownGracePeriodSeconds: 120 # default is 120
  resources:
    requests:
      memory: "12Gi"
      cpu: 2
    limits:
      memory: "12Gi"
      cpu: 2
  nodeSelector:
    starburstpool: ${worker_node_pool}
  tolerations:
    - key: "${node_taint_key}"
      operator: "Exists"
      effect: "NoSchedule"
