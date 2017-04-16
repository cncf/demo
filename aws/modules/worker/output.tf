output "autoscaling-group-name" { value = "${ aws_autoscaling_group.worker.name }" }
output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
