# Input variables
variable region { }
variable zone { }
variable primary_db_instance { }
variable primary_db_version { }
variable primary_db_user { }
variable vpc_id { }
variable create_rds { }

# Get the local public IP (i.e. client running this script)
# Add this to the postgress ingress rule for the DB
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}


# Create the resource
resource "google_sql_database_instance" "primary_db" {
  count                 = var.create_rds ? 1 : 0

  name                  = var.primary_db_instance
  database_version      = var.primary_db_version
  region                = var.region
  deletion_protection   = false

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.    
    tier                    = "db-f1-micro"
    availability_type       = "ZONAL"
    disk_size               = 20  # 10 GB is the smallest disk size

    ip_configuration {
      ipv4_enabled    = true
      private_network = var.vpc_id

      authorized_networks {
        name          = "allow-my-ip"
        value         = "${chomp(data.http.myip.body)}/32"
      }
    }

    database_flags {
      name  = "max_connections"
      value = 100
    }
  }
}

resource "google_sql_user" "primary_db_user" {
  count                 = var.create_rds ? 1 : 0

  name     = var.primary_db_user
  instance = google_sql_database_instance.primary_db[0].name
  password = random_string.primary_db_user[0].result

  depends_on = [google_sql_database_instance.primary_db]
}

resource "random_string" "primary_db_user" {
  count                 = var.create_rds ? 1 : 0

  # Generate a random password for the primary PostgreSQL DB user
  length = 16
  upper  = true
  lower  = true
  number = true
  special = false
}

# Outputs
output "identifier" {
    value       = var.create_rds ? google_sql_database_instance.primary_db[0].name : null
}

output "database_version" {
    value       = var.create_rds ? google_sql_database_instance.primary_db[0].database_version : null
}

output "database_port" {
    value       = var.create_rds ? "5432" : null
}

output "primary_database" {
    value       = var.create_rds ? "postgres" : null
}

output "public_ip_address" {
    value       = var.create_rds ? google_sql_database_instance.primary_db[0].public_ip_address : null
}

output "private_ip_address" {
    value       = var.create_rds ? google_sql_database_instance.primary_db[0].private_ip_address : null
}

output "primary_db_user" {
    value       = var.create_rds ? google_sql_user.primary_db_user[0].name : null
}

output "primary_db_password" {
    value       = var.create_rds ? random_string.primary_db_user[0].result : null
}