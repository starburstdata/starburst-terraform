# Input variables
variable vpc_id { }
variable identifier { }
variable engine { }
variable instance_class { }
variable db_name { }
variable username { }
variable vpc_security_group_id { }
variable eks_security_groups { }
variable subnet_ids { }
variable tags { }
variable create_db_instance { }

# Create the DB subnet group
resource "aws_db_subnet_group" "this" {
  count                       = var.create_db_instance ? 1 : 0

  description                 = "Database subnet group for ${var.identifier}"
  subnet_ids                  = var.subnet_ids
}

# Create the RDS
resource "aws_db_instance" "default" {
    count                     = var.create_db_instance ? 1 : 0
    
    identifier                = var.identifier
    allocated_storage         = 20
    storage_type              = "gp2"
    engine                    = var.engine
    instance_class            = var.instance_class
    name                      = var.db_name
    username                  = var.username
    password                  = random_string.primary_db_user[0].result

    vpc_security_group_ids    = [var.vpc_security_group_id,aws_security_group.rds[0].id]
    db_subnet_group_name      = aws_db_subnet_group.this[0].name

    publicly_accessible       = true
    deletion_protection       = false
    multi_az                  = false
    skip_final_snapshot       = true
    backup_retention_period   = 0

    tags                      = var.tags
}

# Generate a password for the primary DB user
resource "random_string" "primary_db_user" {
    count               = var.create_db_instance ? 1 : 0

    # Generate a random password for the primary PostgreSQL DB user
    length = 16
    upper  = true
    lower  = true
    number = true
    special = false
}

# Get the local public IP (i.e. client running this script)
# Add this to the postgress ingress rule for the DB
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# Add a security group to allow ingress for EKS and
resource "aws_security_group" "rds" {
    count                   = var.create_db_instance ? 1 : 0
    name_prefix             = "postgres"
    vpc_id                  = var.vpc_id

    ingress {
        from_port           = 5432
        to_port             = 5432
        protocol            = "tcp"

        security_groups     = var.eks_security_groups
    }

    ingress {
        from_port           = 5432
        to_port             = 5432
        protocol            = "tcp"
        cidr_blocks         = ["${chomp(data.http.myip.body)}/32"]
    }
  
    revoke_rules_on_delete  = true
}

output identifier {
    value = var.create_db_instance ? aws_db_instance.default[0].identifier : null
}
output address {
    value = var.create_db_instance ? aws_db_instance.default[0].address : null
}
output port {
    value = var.create_db_instance ? aws_db_instance.default[0].port : null
}
output db_name {
    value = var.create_db_instance ? aws_db_instance.default[0].name : null
}
output username {
    value = var.create_db_instance ? aws_db_instance.default[0].username : null
}
output password {
    value = var.create_db_instance ? random_string.primary_db_user[0].result : null
}
output engine {
    value = var.create_db_instance ? aws_db_instance.default[0].engine : null
}
output engine_version {
    value = var.create_db_instance ? aws_db_instance.default[0].engine_version : null
}