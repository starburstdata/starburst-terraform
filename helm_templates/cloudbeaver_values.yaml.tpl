# Default values for cloudbeaver.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

replicaCount: 1

image:
  repository: ${repository}
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.

imagePullSecrets: []
nameOverride: ""
fullnameOverride: ""

serviceAccount:
  # Specifies whether a service account should be created
  create: false
  # Annotations to add to the service account
  annotations: {}
  # The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template
  name: ""

podAnnotations: {}

podSecurityContext: {}
  # fsGroup: 2000

securityContext: {}
  # capabilities:
  #   drop:
  #   - ALL
  # readOnlyRootFilesystem: true
  # runAsNonRoot: true
  # runAsUser: 1000

service:
  type: ${service_type}
  port: 8978
  targetPort: 8978
  name: ${expose_cloudbeaver_name}

ingress:
  enabled: ${enable_ingress}
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: ${secret_key_ref}
    nginx.ingress.kubernetes.io/use-regex: "true"
  hosts:
    - host: ${cloudbeaver_service_prefix}.${dns_zone}
      paths:
      - path: /
        backend:
          serviceName: ${expose_cloudbeaver_name}
          servicePort: 8978
  tls:
    - secretName: tls-secret-cloudbeaver
  #    hosts:
  #      - chart-example.local

resources: {}
  # We usually recommend not to specify default resources and to leave this as a conscious
  # choice for the user. This also increases chances charts run on environments with little
  # resources, such as Minikube. If you do want to specify resources, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  # limits:
  #   cpu: 100m
  #   memory: 128Mi
  # requests:
  #   cpu: 100m
  #   memory: 128Mi

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80
  # targetMemoryUtilizationPercentage: 80

nodeSelector:
  agentpool: ${primary_node_pool}

tolerations: []

affinity: {}
