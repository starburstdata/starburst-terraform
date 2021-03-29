registryCredentials:
  enabled: true
  # Replace this with Docker Registry that you use
  registry: ${registry}
  username: ${repo_username}
  password: ${repo_password}
expose:
  type: "clusterIp"
  clusterIp:
    name: ranger
    ports:
      http:
        port: 6080
  ingress:
    serviceName: "${ranger_service_prefix}-ingress"
    servicePort: 6080
    host: ${ranger_service_prefix}.${dns_zone}
    path: "/"
    pathType: Prefix
    tls:
      enabled: true
      secretName: tls-secret-ranger
    annotations:
      kubernetes.io/ingress.class: nginx
      cert-manager.io/cluster-issuer: ${secret_key_ref}
      nginx.ingress.kubernetes.io/use-regex: "true"
  # admin set values for ranger admin server
admin:
  image:
    repository: "${ranger_admin_repo}"
    pullPolicy: "IfNotPresent"
  #port: 6080
  resources:
    requests:
      memory: 1Gi
      cpu: 1
    limits:
      memory: 1Gi
      cpu: 1
  serviceUser: starburst_service
  passwords:
    admin: ${ranger_svc_acc_pwd1}
    tagsync: ${ranger_svc_acc_pwd2}
    usersync: ${ranger_svc_acc_pwd3}
    keyadmin: ${ranger_svc_acc_pwd4}
    service: ${ranger_svc_acc_pwd5}

usersync:
  enabled: false

database:
  # type is internal | external
  type: external
  external:
    host: ${primary_ip_address}
    port: ${primary_db_port}
    databaseName: ${primary_db_ranger}
    databaseUser: ${ranger_db_user}
    databasePassword: ${ranger_db_password}
    databaseRootUser: ${primary_db_user}
    databaseRootPassword: ${primary_db_password}
# datasources - list of starburst datasources to configure Ranger
# services. It is mounted as file /config/datasources.yaml inside
# container and processed by init script.
datasources:
  - name: starburst-enterprise
    host: "${starburst_service_prefix}-ingress"
    port: 8080
    username: ${ranger_usr} 
    password: ${ranger_pwd}

initFile: files/initFile.sh