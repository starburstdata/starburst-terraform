registryCredentials:
  enabled: true
  registry: ${registry}
  username: ${repo_username}
  password: ${repo_password}

image:
  repository: ${repository}
  pullPolicy: "IfNotPresent"

replicaCount: 1
