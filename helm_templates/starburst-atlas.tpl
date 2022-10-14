affinity: {}
args: []
authentication:
  file:
    enabled: true
    usersCredentialsSecret: ""
command: []
config:
  cassandra:
    clustername: stack-cassandra
    hostname:
    - stack-cassandra
    port: 9042
  kafka:
    hostname:
    - stack-kafka
    port: 9092
  kafkaZookeeper:
    hostname:
    - stack-zookeeper
    port: 2181
  solr:
    hostname:
    - stack-solrcloud-common
    port: 80
  solrZookeeper:
    hostname:
    - stack-zookeeper
    port: 2181
containerPorts:
  http: 21000
  https: 21443
containerSecurityContext: {}
deploymentAnnotations: {}
expose:
  clusterIp:
    name: atlas
    ports:
      http:
        port: 21000
  ingress:
    annotations: {}
    host: ""
    ingressClassName: nginx
    ingressName: atlas-ingress
    path: /
    serviceName: atlas
    servicePort: 21000
    tls:
      enabled: false
      secretName: ""
  loadBalancer:
    IP: ""
    annotations: {}
    name: atlas
    ports:
      http:
        port: 21000
    sourceRanges: []
  nodePort:
    extraLabels: {}
    name: atlas
    ports:
      http:
        nodePort: 31000
        port: 21000
  type: clusterIp
extraEnvVars: []
extraVolumeMounts: []
extraVolumes: []
image:
  pullPolicy: IfNotPresent
  repository: harbor.starburstdata.net/starburstdata/starburst-atlas
  tag: 2.2.0-e.1
imagePullSecrets: []
initContainers: []
kafka:
  auth:
    enabled: false
    sasl:
      jaas:
        password: kafkaPassword
        user: kafkaUser
    tls:
      jksTruststoreSecret: kafka-truststore
      truststorePassword: ""
nodeSelector: {}
podAnnotations: {}
podSecurityContext: {}
propertiesFile:
  entityAuditRepositorySection: |
    atlas.EntityAuditRepository.impl=org.apache.atlas.repository.audit.CassandraBasedAuditRepository
    atlas.EntityAuditRepository.keyspace=atlas_audit
    atlas.EntityAuditRepository.replicationFactor=1
  graphDatabaseSection: ""
  graphIndexSection: |
    atlas.graph.index.search.backend=solr
    atlas.graph.index.search.solr.mode=cloud
    atlas.graph.index.search.solr.zookeeper-url={{ include "starburst-atlas.format.servers" .Values.config.solrZookeeper }}
    atlas.graph.index.search.solr.zookeeper-connect-timeout=60000
    atlas.graph.index.search.solr.zookeeper-session-timeout=60000
    atlas.graph.index.search.solr.wait-searcher=false
    atlas.graph.index.search.max-result-set-size=150
  graphStorageSection: |
    atlas.graph.storage.backend=cql
    atlas.graph.storage.hostname={{ .Values.config.cassandra.hostname | join "," }}
    atlas.graph.storage.clustername={{ .Values.config.cassandra.clustername }}
    atlas.graph.storage.port={{ .Values.config.cassandra.port }}
  kafkaSecurityPropertiesSection: |
    atlas.kafka.ssl.truststore.location=/opt/atlas/conf/kafka.truststore.jks
    atlas.kafka.ssl.truststore.password={{ .Values.kafka.auth.tls.truststorePassword }}
    atlas.kafka.security.protocol=SASL_SSL
    atlas.kafka.sasl.mechanism=PLAIN

    atlas.jaas.KafkaClient.loginModuleName=org.apache.kafka.common.security.plain.PlainLoginModule
    atlas.jaas.KafkaClient.loginModuleControlFlag=required
    atlas.jaas.KafkaClient.option.username={{ .Values.kafka.auth.sasl.jaas.user }}
    atlas.jaas.KafkaClient.option.password={{ .Values.kafka.auth.sasl.jaas.password }}
    atlas.jaas.KafkaClient.option.mechanism=PLAIN
    atlas.jaas.KafkaClient.option.protocol=SASL_SSL
  notificationConfigSection: |
    atlas.notification.embedded=false
    atlas.kafka.data=/opt/atlas/data/kafka
    atlas.kafka.zookeeper.connect={{ include "starburst-atlas.format.servers" .Values.config.kafkaZookeeper }}
    atlas.kafka.bootstrap.servers={{ include "starburst-atlas.format.servers" .Values.config.kafka }}
    atlas.kafka.zookeeper.session.timeout.ms=400
    atlas.kafka.zookeeper.connection.timeout.ms=200
    atlas.kafka.zookeeper.sync.time.ms=20
    atlas.kafka.auto.commit.interval.ms=1000
    atlas.kafka.hook.group.id=atlas

    atlas.kafka.enable.auto.commit=false
    atlas.kafka.auto.offset.reset=earliest
    atlas.kafka.session.timeout.ms=30000
    atlas.kafka.offsets.topic.replication.factor=1
    atlas.kafka.poll.timeout.ms=1000
    atlas.kafka.request.timeout.ms=60000

    atlas.notification.create.topics=true
    atlas.notification.replicas=1
    atlas.notification.topics=ATLAS_HOOK,ATLAS_ENTITIES
    atlas.notification.log.failed.messages=true
    atlas.notification.consumer.retry.interval=500
    atlas.notification.hook.retry.interval=1000
  otherPropertiesSection: |
    atlas.rest.address=http://localhost:{{ .Values.containerPorts.http }}

    atlas.server.run.setup.on.start=false

    atlas.audit.zookeeper.session.timeout.ms=1000

    atlas.server.ha.enabled=false

    atlas.authorizer.impl=simple
    atlas.authorizer.simple.authz.policy.file=atlas-simple-authz-policy.json

    atlas.rest-csrf.enabled=true
    atlas.rest-csrf.browser-useragents-regex=^Mozilla.*,^Opera.*,^Chrome.*
    atlas.rest-csrf.methods-to-ignore=GET,OPTIONS,HEAD,TRACE
    atlas.rest-csrf.custom-header=X-XSRF-HEADER

    atlas.metric.query.cache.ttlInSecs=900

    atlas.search.gremlin.enable=false

    atlas.server.ha.enabled=false
  securityPropertiesSection: |
    atlas.server.http.port={{ .Values.containerPorts.http }}
    atlas.server.https.port={{ .Values.containerPorts.https }}

    atlas.enableTLS=false

    atlas.authentication.method.ldap=false
    atlas.authentication.method.ldap.type=none
    atlas.authentication.method.kerberos=false

    atlas.authentication.method.file={{ .Values.authentication.file.enabled }}
    atlas.authentication.method.file.filename=/opt/atlas/conf/users-credentials.properties
registryCredentials:
  enabled: false
  password: 
  registry: harbor.starburstdata.net
  username: 
resources:
  limits: {}
  requests: {}
serviceAccount:
  annotations: {}
  create: true
  name: starburst-atlas
sidecars: []
solr:
  auth:
    adminPassword: ""
    enabled: false
    securityBootstrapSecret: stack-solrcloud-security-bootstrap
tolerations: []