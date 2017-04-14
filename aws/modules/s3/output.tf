output "bucket" { value = "${ aws_s3_bucket.ssl.bucket }" }
output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
