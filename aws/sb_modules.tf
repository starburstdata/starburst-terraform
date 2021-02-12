# Kubernetes Applications to be deployes
#
# If you do not want Terraform to deploy a resource, set the apropriate create_<resource> flag to false in terraform.ftvars
#
# Everything that needs to be deployed to kubernetes for this environment should go here.
# Current modules include:
#                           modules/hive
#                           modules/ranger
#                           modules/trino
#                           modules/mc (Mission Control)
#                           

module hive {
    source                  = "../modules/hive"
    
    # Helm Chart Repo
    registry                = var.registry
    repository              = var.repository
    repo_version            = local.hms_version
    repo_username           = var.repo_username
    repo_password           = var.repo_password
    
    # External Postgres details. If an external postgres DB is not being created, just pass in dummy values
    hive_service            = var.hive_service
    primary_ip_address      = var.create_rds ? module.db.address : "dummy"
    primary_db_port         = var.create_rds ? module.db.port : "1000"
    primary_db_user         = var.create_rds ? module.db.username : "dummy"
    primary_user_password   = var.create_rds ? module.db.password : "dummy"
    primary_db_hive         = "hive"
    hive_template_file      = "${path.root}/../helm_templates/${local.hive_yaml_file}"
    type                    = var.create_rds ? "external" : "internal"
    
    # Object storage credentials
    # GCS
    gcp_cloud_key_secret    = local.gcp_cloud_key_secret
    # ADL
    adl_oauth2_client_id    = local.adl_oauth2_client_id
    adl_oauth2_credential   = local.adl_oauth2_credential
    adl_oauth2_refresh_url  = local.adl_oauth2_refresh_url
    # AWS S3
    s3_access_key           = local.s3_access_key
    s3_endpoint             = local.s3_endpoint
    s3_region               = local.s3_region
    s3_secret_key           = local.s3_secret_key
    # Azure ADLS
    abfs_access_key         = local.abfs_access_key
    abfs_storage_account    = local.abfs_storage_account
    abfs_auth_type          = local.abfs_auth_type
    abfs_client_id          = local.abfs_client_id
    abfs_endpoint           = local.abfs_endpoint
    abfs_secret             = local.abfs_secret
    wasb_access_key         = local.wasb_access_key
    wasb_storage_account    = local.wasb_storage_account

    # Node pools to deploy to
    primary_node_pool       = var.primary_node_pool

    # Conditional create logic
    create_hive             = var.create_hive

    depends_on              = [postgresql_database.database,module.eks]
}

module mc {
    source                  = "../modules/mc"

    environment             = local.env

    # Helm Chart Repo
    registry                = var.registry
    repository              = var.repository
    repo_version            = local.mc_version
    presto_version          = var.presto_version
    repo_username           = var.repo_username
    repo_password           = var.repo_password
    
    # External Postgres details
    primary_ip_address      = var.create_rds ? module.db.address : "dummy"
    primary_db_port         = var.create_rds ? module.db.port : "1000"
    primary_db_user         = var.create_rds ? module.db.username : "dummy"
    primary_user_password   = var.create_rds ? module.db.password : "dummy"
    primary_db_mc           = "mcdemo"
    mc_template_file        = "${path.root}/../helm_templates/${local.mc_yaml_file}"
    operator_template_file  = "${path.root}/../helm_templates/${local.operator_yaml_file}"
    type                    = "internal" #var.create_rds ? "external" : "internal"
    service_type            = var.create_nginx ? "ingress" : "loadBalancer"
       
    # MC Service Name
    mc_service              = local.mc_service

    # Expose this service name
    expose_mc_name          = var.expose_mc_name

    # DNS Zone for Ranger endpoint
    dns_zone                = var.dns_zone

    # Node pools to deploy to
    primary_node_pool       = var.primary_node_pool

    # Conditional create logic
    create_mc               = var.create_mc

    depends_on              = [postgresql_database.database,module.eks]
}

module ranger {
    source                  = "../modules/ranger"

    environment             = local.env

    # Helm Chart Repo
    registry                = var.registry
    repository              = var.repository
    repo_version            = local.ranger_version
    repo_username           = var.repo_username
    repo_password           = var.repo_password

    # External Postgres details
    primary_ip_address      = var.create_rds ? module.db.address : "dummy"
    primary_db_port         = var.create_rds ? module.db.port : "1000"
    primary_db_user         = var.create_rds ? module.db.username : "dummy"
    primary_user_password   = var.create_rds ? module.db.password : "dummy"
    primary_db_ranger       = "ranger"
    ranger_template_file    = "${path.root}/../helm_templates/${local.ranger_yaml_file}"
    type                    = var.create_rds ? "external" : "internal"
    service_type            = var.create_nginx ? "ingress" : "loadBalancer"

    # Admin user login user details
    admin_user              = var.admin_user
    admin_pass              = random_string.admin_pass.result

    # Ranger & Presto Service names
    ranger_service          = local.ranger_service
    presto_service          = local.presto_service

    # Expose this service name
    expose_ranger_name      = var.expose_ranger_name

    # DNS Zone for Ranger endpoint
    dns_zone                = var.dns_zone
    
    # Node pools to deploy to
    primary_node_pool       = var.primary_node_pool

    # Conditional create logic
    create_ranger           = var.create_ranger

    depends_on              = [postgresql_database.database,module.hive]
}

module trino {
    source                  = "../modules/trino"

    environment             = local.env

    # Helm Chart Repo
    registry                = var.registry
    repository              = var.repository
    repo_version            = local.sb_version
    repo_username           = var.repo_username
    repo_password           = var.repo_password

    # External Postgres details
    primary_ip_address      = var.create_rds ? module.db.address : "dummy"
    primary_db_port         = var.create_rds ? module.db.port : "1000"
    primary_db_user         = var.create_rds ? module.db.username : "dummy"
    primary_user_password   = var.create_rds ? module.db.password : "dummy"
    primary_db_event_logger = "event_logger"
    primary_db_ranger       = "ranger"
    trino_template_file     = "${path.root}/../helm_templates/${local.trino_yaml_file}"
    service_type            = var.create_nginx ? "ingress" : "loadBalancer"

    # Admin user login user details
    admin_user              = var.admin_user
    admin_pass              = random_string.admin_pass.result

    # Ranger & Presto Service names
    ranger_service          = local.ranger_service
    presto_service          = local.presto_service

    # Expose this service name
    expose_sb_name          = var.expose_sb_name

    # DNS Zone for Ranger endpoint
    dns_zone                = var.dns_zone
    
    # Node pools to deploy to
    primary_node_pool       = var.primary_node_pool
    worker_node_pool        = var.worker_node_pool

    # Conditional create logic
    create_trino            = var.create_trino

    depends_on              = [postgresql_database.database,module.hive]
}

module nginx {
    source                  = "../modules/nginx"

    environment             = local.env
    email                   = var.email
    primary_node_pool       = var.primary_node_pool

    create_nginx            = var.create_nginx

    depends_on              = [module.eks]
}

module dns {
    source                  = "../modules/aws-dns"

    presto_service          = local.presto_service
    ranger_service          = local.ranger_service
    mc_service              = local.mc_service
    dns_zone                = var.dns_zone
    create_nginx            = var.create_nginx

    depends_on              = [module.nginx]   
}