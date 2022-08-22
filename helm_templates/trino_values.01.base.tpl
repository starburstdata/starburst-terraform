registryCredentials:
  enabled: true
  registry: ${registry}
  username: ${repo_username}
  password: ${repo_password}

starburstPlatformLicense: "starburst"

sharedSecret: ${int_comm_shared_secret}

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
      memory: ${coordinator_mem}
      cpu: ${coordinator_cpu}
    limits:
      memory: ${coordinator_mem}
      cpu: ${coordinator_cpu}
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
      config.properties: |
          coordinator=false
          http-server.http.port=8080
          discovery.uri=http://coordinator:8080
  autoscaling:
    enabled: true
    minReplicas: ${worker_autoscaling_min_size}
    maxReplicas: ${worker_autoscaling_max_size}
    targetCPUUtilizationPercentage: ${targetCPUUtilizationPercentage} # For demo and testing you can set this lower to someting like 50.
  deploymentTerminationGracePeriodSeconds: ${deploymentTerminationGracePeriodSeconds} # default is 300; it is actually how long the graceful shutdown waits after it receives the SIGTERM
  starburstWorkerShutdownGracePeriodSeconds: ${starburstWorkerShutdownGracePeriodSeconds} # default is 120
  resources:
    requests:
      memory: ${worker_mem}
      cpu: ${worker_cpu}
    limits:
      memory: ${worker_mem}
      cpu: ${worker_cpu}
  nodeSelector:
    starburstpool: ${worker_node_pool}
  tolerations:
    - key: "${node_taint_key}"
      operator: "Exists"
      effect: "NoSchedule"
