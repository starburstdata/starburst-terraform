registryCredentials:
  enabled: true
  # Replace this with Docker Registry that you use
  registry: ${registry}
  username: ${repo_username}
  password: ${repo_password}
# admin set values for ranger admin server
image:
  repository: "${repository}"
  pullPolicy: "IfNotPresent"

expose:
  clusterIp:
    name: hive
    ports:
      http:
        port: 9083
  ingress:
    annotations: {}
    host: null
    ingressClassName: null
    ingressName: hive-ingress
    path: /
    serviceName: hive
    servicePort: 9083
    tls:
      enabled: true
      secretName: null
  nodePort:
    name: hive
    ports:
      http:
        nodePort: 30083
        port: 9083
  type: clusterIp

database:
  # type is internal | external
  type: ${type}
  internal:
    resources:
      requests:
        memory: "1Gi"
        cpu: 0.25
      limits:
        memory: "1Gi"
        cpu: 1
  external:
    # docker container supported drivers: com.mysql.jdbc.Driver or org.postgresql.Driver
    jdbcUrl: "jdbc:postgresql://${primary_ip_address}:${primary_db_port}/${primary_db_hive}"
    driver: org.postgresql.Driver
    user: "${primary_db_user}"
    password: "${primary_db_password}"

hdfs:
  hadoopUserName:

objectStorage:
  adl:
    oauth2:
      clientId: ${adl_oauth2_client_id}
      credential: ${adl_oauth2_credential}
      refreshUrl: ${adl_oauth2_refresh_url}
  awsS3:
    accessKey: ${s3_access_key}
    endpoint: ${s3_endpoint}
    pathStyleAccess: false
    region: ${s3_region}
    secretKey: ${s3_secret_key}
  azure:
    abfs:
      accessKey:
        accessKey: ${abfs_access_key}
        storageAccount: ${abfs_storage_account}
      authType: ${abfs_auth_type}
      oauth:
        clientId: ${abfs_client_id}
        endpoint: ${abfs_endpoint}
        secret: ${abfs_secret}
    wasb:
      accessKey: ${wasb_access_key}
      storageAccount: ${wasb_storage_account}
  gs:
    cloudKeyFileSecret: ${gcp_cloud_key_secret}

heapSizePercentage: 85

resources:
  requests:
    memory: 1Gi
    cpu: 1
  limits:
    memory: 1Gi
    cpu: 1

nodeSelector: {}

affinity: {}