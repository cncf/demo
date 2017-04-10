output "s3_bucket" { value = "${ var.s3_bucket }" }
output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
