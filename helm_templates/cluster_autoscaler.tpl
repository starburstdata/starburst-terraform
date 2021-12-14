cloudProvider: aws
awsRegion: ${region}

autoscaler:
  image:
    repository: us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler
    tag: ${cluster_autoscaler_tag} # use the k8s cluster version x.y versions - don't update to latest
#   pullSecrets:
#     - name: dockercredentials

# This needs to be updated to match the cluster name you are deploying this into.
autoDiscovery:
  enabled: true
  clusterName: ${cluster_name}
  # tags:
  #   - k8s.io/cluster-autoscaler/enabled
  #   - k8s.io/cluster-autoscaler/${cluster_name}

rbac:
  create: true

extraArgs:
  skip-nodes-with-local-storage: "false"
  skip-nodes-with-system-pods: "false"
  balance-similar-node-groups: "true"
  expander: "least-waste"

priorityClassName: "node-autoscaler"

service:
  labels:
    app: node-autoscaler
    
resources:
  limits:
    cpu: 100m
    memory: 500Mi
  requests:
    cpu: 100m
    memory: 500Mi