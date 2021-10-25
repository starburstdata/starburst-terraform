registryCredentials:
  enabled: true
  # Replace this with Docker Registry that you use
  registry: ${registry}
  username: ${repo_username}
  password: ${repo_password}
expose:
  type: ${service_type} #"loadBalancer"
  loadBalancer:
    name: ${expose_ranger_name}
    ports:
      http:
        port: 6080
  ingress:
    serviceName: ${expose_ranger_name}
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

admin:
  resources:
    requests:
      memory: ${ranger_mem}
      cpu: ${ranger_cpu}
    limits:
      memory: ${ranger_mem}
      cpu: ${ranger_cpu}
  passwords:
    admin: ${ranger_svc_acc_pwd1}
    tagsync: ${ranger_svc_acc_pwd2}
    usersync: ${ranger_svc_acc_pwd3}
    keyadmin: ${ranger_svc_acc_pwd4}
    service: ${ranger_svc_acc_pwd5}
  serviceUser: ${admin_user}
    
database:
  resources:
    requests:
      memory: "1Gi"
      cpu: 0.5
    limits:
      memory: "1Gi"
      cpu: 1
  type: ${type}
  external:
    host: ${primary_ip_address}
    port: ${primary_db_port}
    databaseName: ${primary_db_ranger}
    databaseUser: ${ranger_db_user}
    databasePassword: ${ranger_db_password}
    databaseRootUser: ${primary_db_user}
    databaseRootPassword: ${primary_db_password}

datasources:
  - name: starburst-enterprise
    host: coordinator
    port: 8080
    username: ${admin_user} 
    password: ${admin_pass}

initFile: files/initFile.sh