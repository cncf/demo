output "endpoint" { value = "${ google_container_cluster.cncf.endpoint }" }

output "ca" { value = "${ base64decode(google_container_cluster.cncf.master_auth.0.cluster_ca_certificate) }" }

output "admin" { value = "${ base64decode(google_container_cluster.cncf.master_auth.0.client_certificate) }" }

output "admin_key" { value = "${ base64decode(google_container_cluster.cncf.master_auth.0.client_key) }" }
