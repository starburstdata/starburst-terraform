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
  enabled: true
  users:
    - username: ${admin_user}
      password: ${admin_pass}
    - username: ${reg_user1}
      password: ${reg_pass1}
    - username: ${reg_user2}
      password: ${reg_pass2}

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
        insights.persistence-enabled=true
        insights.metrics-persistence-enabled=true
        insights.jdbc.url=jdbc:postgresql://${primary_ip_address}:${primary_db_port}/${primary_db_event_logger}
        insights.jdbc.user=${primary_db_user}
        insights.jdbc.password=${primary_db_password}
      access-control.properties: |
        access-control.name=ranger
        ranger.authentication-type=BASIC
        ranger.policy-rest-url=http://${expose_ranger_name}:6080
        ranger.service-name=starburst-enterprise
        ranger.presto-plugin-username=${admin_user}
        ranger.presto-plugin-password=${admin_pass}
        ranger.policy-refresh-interval=10s
      event-listener.properties: |
        event-listener.name=event-logger
        jdbc.url=jdbc:postgresql://${primary_ip_address}:${primary_db_port}/${primary_db_event_logger}
        jdbc.user=${primary_db_user}
        jdbc.password=${primary_db_password}
      password-authenticator.properties: |
        password-authenticator.name=file
  nodeSelector:
    agentpool: ${primary_node_pool}

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
      event-listener.properties: |
        event-listener.name=event-logger
        jdbc.url=jdbc:postgresql://${primary_ip_address}:${primary_db_port}/${primary_db_event_logger}
        jdbc.user=${primary_db_user}
        jdbc.password=${primary_db_password}
  autoscaling:
    enabled: true
    minReplicas: 1
    maxReplicas: 10
  resources:
    requests:
      memory: "10Gi"
      cpu: 1
    limits:
      memory: "10Gi"
      cpu: 1
  nodeSelector:
    agentpool: ${worker_node_pool}

catalogs:
  tpcds: |
    connector.name=tpcds
  jmx: |
    connector.name=jmx
  postgres: |
    connector.name=postgresql
    connection-url=jdbc:postgresql://${primary_ip_address}:${primary_db_port}/${demo_db_name}
    connection-user=${primary_db_user}
    connection-password=${primary_db_password}
  hive: |
    connector.name=hive-hadoop2
    hive.allow-drop-table=true
    hive.metastore.uri=${hive_service_url}

