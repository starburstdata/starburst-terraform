fullnameOverride: ${expose_postgres_name}

global:
  postgresql:
    postgresqlDatabase: postgres
    postgresqlUsername: ${primary_db_user}
    postgresqlPassword: ${primary_db_password}
    servicePort: 5432

initdbScripts:
  init.sql: create database ${primary_db_hive}; create database ${primary_db_ranger}; create database ${primary_db_insights}; create database ${primary_db_cache};

service:
  type: ClusterIP
