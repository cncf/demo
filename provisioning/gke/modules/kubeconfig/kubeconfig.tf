
data "template_file" "kubeconfig" {
  template = <<EOF
kubectl config set-cluster gke_${ var.project }_${ var.zone }-a_${ var.name } \
  --server=https://${ var.endpoint } \
  --certificate-authority=/cncf/ca.pem

kubectl config set-credentials gke_${ var.project }_${ var.zone }-a_${ var.name } \
  --certificate-authority=/cncf/ca.pem \
  --client-key=/cncf/admin_key.pem \
  --client-certificate=/cncf/admin.pem

kubectl config set-context gke_${ var.project }_${ var.zone }-a_${ var.name } \
  --cluster=gke_${ var.project }_${ var.zone }-a_${ var.name } \
  --user=gke_${ var.project }_${ var.zone }-a_${ var.name }

kubectl config use-context gke_${ var.project }_${ var.zone }-a_${ var.name }
EOF
}

# resource "null_resource" "kubeconfig" {

#   provisioner "local-exec" {
#     command = <<LOCAL_EXEC
# export KUBECONFIG="/cncf/kubeconfig"

# kubectl config set-cluster gke_${ var.project }_${ var.zone }-a_${ var.name } \
#   --server=https://${ var.endpoint } \
#   --certificate-authority-data=/cncf/ca.pem &&\
# kubectl config set-credentials gke_${ var.project }_${ var.zone }-a_${ var.name } \
#   --certificate-authority-data=/cncf/ca.pem \
#   --client-key-data=/cncf/admin_key.pem \
#   --client-certificate-data=/cncf/admin.pem &&\
# kubectl config set-context gke_${ var.project }_${ var.zone }-a_${ var.name }  \
#   --cluster=gke_${ var.project }_${ var.zone }-a_${ var.name } \
#   --user=gke_${ var.project }_${ var.zone }-a_${ var.name } &&\
# kubectl config use-context gke_${ var.project }_${ var.zone }-a_${ var.name }
# LOCAL_EXEC
#   }

# }
