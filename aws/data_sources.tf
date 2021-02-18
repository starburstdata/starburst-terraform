locals {
    # Object storage credentials
    # GCS
    gcp_cloud_key_secret    = var.gcp_cloud_key_secret
    # ADL
    adl_oauth2_client_id    = var.adl_oauth2_client_id
    adl_oauth2_credential   = var.adl_oauth2_credential
    adl_oauth2_refresh_url  = var.adl_oauth2_refresh_url
    # AWS S3
    s3_access_key           = var.s3_access_key
    s3_endpoint             = var.s3_endpoint
    s3_region               = var.s3_region
    s3_secret_key           = var.s3_secret_key
    # Azure ADLS
    abfs_access_key         = var.abfs_access_key
    abfs_storage_account    = var.abfs_storage_account
    abfs_auth_type          = var.abfs_auth_type
    abfs_client_id          = var.abfs_client_id
    abfs_endpoint           = var.abfs_endpoint
    abfs_secret             = var.abfs_secret
    wasb_access_key         = var.wasb_access_key
    wasb_storage_account    = var.wasb_storage_account
}