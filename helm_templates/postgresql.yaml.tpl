fullnameOverride: ${expose_postgres_name}
nameOverride: ${expose_postgres_name}

global:
  postgresql:
    auth:
      database: postgres
      username: ${primary_db_user}
      postgresPassword: ${primary_db_password}

shmVolume:
  enabled: false

primary:
  persistence:
    enabled: false
  initdb:
    scripts:
      init.sql: |
        create database ${primary_db_hive};
        create database ${primary_db_ranger};
        create database ${primary_db_insights};
        create database ${primary_db_cache};

service:
  type: ClusterIP

resources:
  requests:
    memory: ${postgres_mem}
    cpu: ${postgres_cpu}
