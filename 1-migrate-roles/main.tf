locals {
  manager_roles = [
    "roles/cloudmigration.inframanager",
    "roles/cloudmigration.storageaccess",
    "roles/iam.serviceAccountUser",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/iam.serviceAccountTokenCreator"
  ]

  extension_roles = [
    "roles/cloudmigration.storageaccess",
    "roles/monitoring.metricWriter",
    "roles/logging.logWriter"
  ]
}

resource "google_service_account" "migrate_manager" {
  account_id   = "migrate-manager"
  display_name = "migrate-manager"
  project      = var.project_id
}

resource "google_service_account" "migrate_extension" {
  account_id   = "migrate-extension"
  display_name = "migrate-extension"
  project      = var.project_id
}

resource "google_project_iam_member" "manager_sa_roles" {
  for_each = toset(local.manager_roles)
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:${google_service_account.migrate_manager.email}"
}

resource "google_project_iam_member" "ext_sa_roles" {
  for_each = toset(local.extension_roles)
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:${google_service_account.migrate_extension.email}"
}


# module "vpc" {
#   source  = "terraform-google-modules/network/google"
#   version = "~> 1.4.3"

#   project_id   = var.project_id
#   network_name = var.network_name

#   delete_default_internet_gateway_routes = true
#   shared_vpc_host                        = false

#   subnets = [
#     {
#       subnet_name   = "${var.network_name}-subnet-01"
#       subnet_ip     = var.subnet_01_ip
#       subnet_region = var.subnet_01_region
#     },
#     {
#       subnet_name           = "${var.network_name}-subnet-02"
#       subnet_ip             = var.subnet_02_ip
#       subnet_region         = var.subnet_01_region
#       subnet_private_access = true
#       subnet_flow_logs      = false
#     },
#     {
#       subnet_name           = "${var.network_name}-subnet-03"
#       subnet_ip             = var.subnet_03_ip
#       subnet_region         = var.subnet_01_region
#       subnet_private_access = true
#       subnet_flow_logs      = false
#     },
#   ]

# }

# Firewall rules
# resource "google_compute_firewall" "velos-backend-control" {
#   name          = "velos-backend-control"
#   description   = "Control plane between Velostrata Backend and Velostrata Manager"
#   network       = var.network_name
#   project       = var.project_id
#   source_ranges = [var.local_subnet_01_ip]
#   target_tags   = ["fw-velosmanager"]
#   depends_on    = [module.vpc]

#   allow {
#     protocol = "tcp"
#     ports    = ["9119"]
#   }
# }

# resource "google_compute_firewall" "velos-ce-backend" {
#   name          = "velos-ce-backend"
#   description   = "Encrypted migration data sent from Velostrata Backend to Cloud Extensions"
#   network       = var.network_name
#   project       = var.project_id
#   source_ranges = [var.local_subnet_01_ip]
#   target_tags   = ["fw-velostrata"]
#   depends_on    = [module.vpc]

#   allow {
#     protocol = "tcp"
#     ports    = ["9111"]
#   }
# }

# resource "google_compute_firewall" "velos-ce-control" {
#   name        = "velos-ce-control"
#   description = "Control plane between Cloud Extensions and Velostrata Manager"
#   network     = var.network_name
#   project     = var.project_id
#   source_tags = ["fw-velosmanager"]
#   target_tags = ["fw-velostrata"]
#   depends_on  = [module.vpc]

#   allow {
#     protocol = "tcp"
#     ports    = ["443", "9111"]
#   }
# }

# resource "google_compute_firewall" "velos-ce-cross" {
#   name        = "velos-ce-cross"
#   description = "Synchronization between Cloud Extension nodes"
#   network     = var.network_name
#   project     = var.project_id
#   source_tags = ["fw-velostrata"]
#   target_tags = ["fw-velostrata"]
#   depends_on  = [module.vpc]

#   allow {
#     protocol = "all"
#   }
# }

# resource "google_compute_firewall" "velos-console-probe" {
#   name        = "velos-console-probe"
#   description = "Allows the Velostrata Manager to check if the SSH or RDP console on the migrated VM is available"
#   network     = var.network_name
#   project     = var.project_id
#   source_tags = ["fw-velosmanager"]
#   target_tags = ["fw-workload"]
#   depends_on  = [module.vpc]

#   allow {
#     protocol = "tcp"
#     ports    = ["22", "3389"]
#   }
# }

# resource "google_compute_firewall" "velos-vcplugin" {
#   name          = "velos-vcplugin"
#   description   = "Control plane between vCenter plugin and Velostrata Manager"
#   network       = var.network_name
#   project       = var.project_id
#   source_ranges = [var.local_subnet_01_ip]
#   target_tags   = ["fw-velosmanager"]
#   depends_on    = [module.vpc]

#   allow {
#     protocol = "tcp"
#     ports    = ["443"]
#   }
# }

# resource "google_compute_firewall" "velos-webui" {
#   name          = "velos-webui"
#   description   = "HTTPS access to Velostrata Manager for web UI"
#   network       = var.network_name
#   project       = var.project_id
#   source_ranges = [var.local_subnet_01_ip, "10.10.20.0/24"]
#   target_tags   = ["fw-velosmanager"]
#   depends_on    = [module.vpc]

#   allow {
#     protocol = "tcp"
#     ports    = ["443"]
#   }
# }

# resource "google_compute_firewall" "velos-workload" {
#   name          = "velos-workload"
#   description   = "iSCSI for data migration and syslog"
#   network       = var.network_name
#   project       = var.project_id
#   source_ranges = [var.local_subnet_01_ip, "10.10.20.0/24"]
#   target_tags   = ["fw-velosmanager"]
#   depends_on    = [module.vpc]

#   allow {
#     protocol = "tcp"
#     ports    = ["3260"]
#   }
#   allow {
#     protocol = "udp"
#     ports    = ["514"]
#   }
# }

# Service Accounts
# resource "google_service_account" "velos-manager" {
#   account_id   = "velos-manager"
#   display_name = "velos-manager"
#   project      = var.project_id
# }

# resource "google_service_account" "velos-cloud-extension" {
#   account_id   = "velos-cloud-extension"
#   display_name = "velos-cloud-extension"
#   project      = var.project_id
# }

# # Roles
# resource "google_project_iam_binding" "iam" {
#   count   = length(local.bindings)
#   project = var.project_id
#   role    = local.bindings[count.index].role
#   members = local.bindings[count.index].members
# }