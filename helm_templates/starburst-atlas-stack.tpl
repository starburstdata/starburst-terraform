cassandra:
  dbUser:
    user: cassandra
  enabled: true
  existingSecret: ""
  extraEnvVars:
  - name: CASSANDRA_AUTHENTICATOR
    value: AllowAllAuthenticator
  - name: CASSANDRA_AUTHORIZER
    value: AllowAllAuthorizer
  fullnameOverride: stack-cassandra
  replicaCount: 1
  resources:
    limits: {}
    requests: {}
  usePasswordFile: false
kafka:
  enabled: true
  externalZookeeper:
    servers:
    - stack-zookeeper
  fullnameOverride: stack-kafka
  offsetsTopicReplicationFactor: 1
  replicaCount: 1
  resources:
    limits: {}
    requests: {}
  zookeeper:
    auth:
      enabled: false
    enabled: false
solr:
  enabled: true
  fullnameOverride: stack-solr
  podOptions:
    resources: {}
  replicas: 1
  solrOptions:
    javaOpts: -Dsolr.disableConfigSetsCreateAuthChecks=true
  zk:
    address: stack-zookeeper:2181
solr-operator:
  enabled: true
  resources: {}
  zookeeper-operator:
    install: false
starburst-atlas:
  enabled: true
  resources:
    limits: {}
    requests: {}
zookeeper:
  auth:
    clientPassword: ""
    clientUser: ""
    enabled: false
    serverPasswords: ""
    serverUsers: ""
  enabled: true
  fullnameOverride: stack-zookeeper
  replicaCount: 1
  resources:
    requests:
      cpu: 250m
      memory: 256Mi
zookeeper-extra:
  enabled: false