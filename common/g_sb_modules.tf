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

module db {
    source                  = "../modules/postgres"

    expose_postgres_name    = var.expose_postgres_name
    primary_db_user         = "postgres"
    primary_node_pool       = var.primary_node_pool
    postgres_template_file  = "${path.root}/../helm_templates/${local.postgres_yaml_file}"
    wait_this_long          = var.wait_this_long

    create_rds              = var.create_rds

    depends_on              = [module.k8s]
}

module hive {
    source                  = "../modules/hive"
    
    # Helm Chart Repo
    registry                = var.registry
    repository              = var.repository
    repo_version            = local.hms_version
    repo_username           = var.repo_username
    repo_password           = var.repo_password
    
    # Check if an external Hive DB has been specified and use that, else use whatever is returned from the RDS module
    hive_service            = var.hive_service
    hive_service_type       = var.hive_service_type
    primary_ip_address      = var.ex_hive_instance != "" ? var.ex_hive_instance : module.db.db_address
    primary_db_port         = var.ex_hive_instance != "" ? var.ex_hive_port : module.db.db_port
    primary_db_user         = var.ex_hive_instance != "" ? var.ex_hive_db_user : module.db.primary_db_user
    primary_user_password   = var.ex_hive_instance != "" ? var.ex_hive_db_password : module.db.primary_db_password
    primary_db_hive         = var.ex_hive_instance != "" ? var.ex_hive_db : "hive"
    hive_yaml_files         = local.hive_yaml_files

    # If I'm not creating an RDS & I'm not specifying an external Hive instance, then this must 
    # be an internal HMS deployment. All other situations mean an external Hive instance is in play
    type                    = var.create_rds == false && var.ex_hive_instance == "" ? "internal" : "external"

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
    # Does the Hive Service need to be created?
    create_hive             = var.create_hive
    # Was the RDS created - by module.rds
    create_rds              = var.create_rds
    # Does the HMS DB need to be created? Derived from determining if an external Hive DB has been defined
    create_hive_db          = var.ex_hive_instance == "" ? true : false

    # External HMS
    ex_hive_server_url      = var.ex_hive_server_url

    depends_on              = [module.k8s,module.db]
}

module mc {
    source                  = "../modules/mc"

    environment             = local.env

    # Helm Chart Repo
    registry                = var.registry
    repository              = var.repository
    repo_version            = local.mc_version
    starburst_version       = var.starburst_version
    repo_username           = var.repo_username
    repo_password           = var.repo_password
    
    # External Postgres details
    primary_ip_address      = var.ex_mc_instance != "" ? var.ex_mc_instance : module.db.db_address
    primary_db_port         = var.ex_mc_instance != "" ? var.ex_mc_port : module.db.db_port
    primary_db_user         = var.ex_mc_instance != "" ? var.ex_mc_db_user : module.db.primary_db_user
    primary_user_password   = var.ex_mc_instance != "" ? var.ex_mc_db_password : module.db.primary_db_password
    primary_db_mc           = var.ex_mc_instance != "" ? var.ex_mc_db : "mcdemo"
    mc_template_file        = "${path.root}/../helm_templates/${local.mc_yaml_file}"
    operator_template_file  = "${path.root}/../helm_templates/${local.operator_yaml_file}"
    type                    = var.create_rds == false && var.ex_mc_instance == "" ? "internal" : "external"
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
    create_rds              = var.create_rds
    create_mc_db            = var.ex_mc_instance == "" ? true : false

    depends_on              = [module.nginx,module.dns,module.k8s,module.db]
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
    primary_ip_address      = var.ex_ranger_instance != "" ? var.ex_ranger_instance : module.db.db_address
    primary_db_port         = var.ex_ranger_instance != "" ? var.ex_ranger_port : module.db.db_port
    primary_db_user         = var.ex_ranger_instance != "" ? var.ex_ranger_root_user : module.db.primary_db_user
    primary_user_password   = var.ex_ranger_instance != "" ? var.ex_ranger_root_password : module.db.primary_db_password
    primary_db_ranger       = var.ex_ranger_instance != "" ? var.ex_ranger_db : "ranger"
    ranger_db_user          = var.ex_ranger_instance != "" ? var.ex_ranger_db_user : "ranger"
    ex_ranger_db_password   = var.ex_ranger_db_password
    ex_ranger_admin_pwd     = var.ex_ranger_admin_pwd
    ex_ranger_keyadmin_pwd  = var.ex_ranger_keyadmin_pwd
    ex_ranger_service_pwd   = var.ex_ranger_service_pwd
    ex_ranger_tagsync_pwd   = var.ex_ranger_tagsync_pwd
    ex_ranger_usersync_pwd  = var.ex_ranger_usersync_pwd
    ranger_yaml_files       = local.ranger_yaml_files
    type                    = var.create_rds == false && var.ex_ranger_instance == "" ? "internal" : "external"
    service_type            = var.create_nginx ? "ingress" : "loadBalancer"

    # Admin user login user details
    admin_user              = var.admin_user
    admin_pass              = local.admin_pass

    # Ranger & starburst Service names
    ranger_service          = local.ranger_service
    starburst_service       = local.starburst_service

    # Expose this service name
    expose_ranger_name      = var.expose_ranger_name
    expose_sb_name          = var.expose_sb_name

    # DNS Zone for Ranger endpoint
    dns_zone                = var.dns_zone
    
    # Node pools to deploy to
    primary_node_pool       = var.primary_node_pool

    # Conditional create logic
    create_ranger           = var.create_ranger
    create_rds              = var.create_rds
    create_ranger_db        = var.ex_ranger_instance == "" ? true : false

    depends_on              = [module.nginx,module.dns,module.hive,module.db]
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

    ## External Postgres details
    # Insights/Event Logger DB Details
    primary_ip_address      = var.ex_insights_instance != "" ? var.ex_insights_instance : module.db.db_address
    primary_db_port         = var.ex_insights_instance != "" ? var.ex_insights_port : module.db.db_port
    primary_db_user         = var.ex_insights_instance != "" ? var.ex_insights_db_user : module.db.primary_db_user
    primary_user_password   = var.ex_insights_instance != "" ? var.ex_insights_db_password : module.db.primary_db_password
    primary_db_event_logger = var.ex_insights_instance != "" ? var.ex_insights_db : "event_logger"
    # Ranger DB details
    primary_db_ranger        = var.ex_ranger_instance != "" ? var.ex_ranger_db : "ranger"
    ranger_db_ip_address     = var.ex_ranger_instance != "" ? var.ex_ranger_instance : module.db.db_address
    ranger_db_port           = var.ex_ranger_instance != "" ? var.ex_ranger_port : module.db.db_port
    ranger_db_user           = var.ex_ranger_instance != "" ? var.ex_ranger_db_user : module.db.primary_db_user
    ranger_db_password       = var.ex_ranger_instance != "" ? var.ex_ranger_db_password : module.db.primary_db_password
    # Cache Redirection DB Details
    primary_db_cache        = var.ex_cache_instance != "" ? var.ex_cache_db : "cache"
    cache_db_ip_address     = var.ex_cache_instance != "" ? var.ex_cache_instance : module.db.db_address
    cache_db_port           = var.ex_cache_instance != "" ? var.ex_cache_port : module.db.db_port
    cache_db_user           = var.ex_cache_instance != "" ? var.ex_cache_db_user : module.db.primary_db_user
    cache_db_password       = var.ex_cache_instance != "" ? var.ex_cache_db_password : module.db.primary_db_password
    trino_yaml_files        = local.trino_yaml_files
    service_type            = var.create_nginx ? "ingress" : "loadBalancer"

    # Demo DB name
    demo_db_name            = module.db.db_name

    # Admin & Regular user login user details
    admin_user              = var.admin_user
    admin_pass              = local.admin_pass
    reg_user1               = var.reg_user1
    reg_pass1               = local.reg_pass1
    reg_user2               = var.reg_user2
    reg_pass2               = local.reg_pass2

    # Ranger & starburst Service names
    ranger_service          = local.ranger_service
    starburst_service       = local.starburst_service

    # ADL
    adl_oauth2_client_id    = local.adl_oauth2_client_id
    adl_oauth2_credential   = local.adl_oauth2_credential
    adl_oauth2_refresh_url  = local.adl_oauth2_refresh_url
    # Azure ADLS
    abfs_access_key         = local.abfs_access_key
    abfs_storage_account    = local.abfs_storage_account
    abfs_auth_type          = local.abfs_auth_type
    abfs_client_id          = local.abfs_client_id
    abfs_endpoint           = local.abfs_endpoint
    abfs_secret             = local.abfs_secret
    wasb_access_key         = local.wasb_access_key
    wasb_storage_account    = local.wasb_storage_account
    # Hive Service URL
    hive_service_url        = module.hive.hive_url

    # Expose this service name
    expose_sb_name          = var.expose_sb_name
    expose_ranger_name      = var.expose_ranger_name

    # DNS Zone for starburst endpoint
    dns_zone                = var.dns_zone
    
    # Node pools to deploy to
    primary_node_pool       = var.primary_node_pool
    worker_node_pool        = var.worker_node_pool

    # Worker pool autoscaling and graceful shutdown
    worker_autoscaling_min_size                 = var.worker_autoscaling_min_size
    worker_autoscaling_max_size                 = var.worker_autoscaling_max_size
    targetCPUUtilizationPercentage              = var.targetCPUUtilizationPercentage
    deploymentTerminationGracePeriodSeconds     = var.deploymentTerminationGracePeriodSeconds
    starburstWorkerShutdownGracePeriodSeconds   = var.starburstWorkerShutdownGracePeriodSeconds

    worker_cpu              = local.worker_cpu
    worker_mem              = local.worker_mem

    # Node taint for spot/preemptible
    node_taint_key          = var.node_taint_key

    # Conditional create logic
    create_trino            = var.create_trino
    create_rds              = var.create_rds
    create_insights_db      = var.ex_insights_instance == "" ? true : false

    depends_on              = [module.nginx,module.dns,module.hive,module.db]
}

module nginx {
    source                  = "../modules/nginx"

    environment             = local.env
    email                   = var.email
    primary_node_pool       = var.primary_node_pool

    create_nginx            = var.create_nginx

    depends_on              = [module.k8s]
}

module cloudbeaver {
    source                  = "../modules/cloudbeaver"

    environment             = local.env

    # Helm Chart Repo
    repository              = "dbeaver/cloudbeaver"

    cloudbeaver_service     = local.cloudbeaver_service
    cloudbeaver_yaml_file   = "${path.root}/../helm_templates/${local.cloudbeaver_yaml_file}"
    service_type            = var.create_nginx ? "ClusterIP" : "LoadBalancer"
    enable_ingress          = var.create_nginx ? "true" : "false"

    # Expose this service name
    expose_cloudbeaver_name = var.expose_cloudbeaver_name

    # DNS Zone for starburst endpoint
    dns_zone                = var.dns_zone
    
    # Node pools to deploy to
    primary_node_pool       = var.primary_node_pool

    # Conditional create logic
    create_cloudbeaver      = var.create_cloudbeaver

    depends_on              = [module.nginx,module.dns,module.hive,module.db]
}