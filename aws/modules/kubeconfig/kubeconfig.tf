data "template_file" "kubeconfig" {
  template = <<EOF
kubectl config set-cluster cluster-${ var.name } \
  --embed-certs=true \
  --server=https://${ var.master_elb } \
  --certificate-authority=${ var.ca_pem }

kubectl config set-credentials admin-${ var.name } \
  --embed-certs=true \
  --certificate-authority=${ var.ca_pem } \
  --client-key=${ var.admin_key_pem } \
  --client-certificate=${ var.admin_pem }

kubectl config set-context ${ var.name } \
  --cluster=cluster-${ var.name } \
  --user=admin-${ var.name }
kubectl config use-context ${ var.name }

# Run this command to configure your kubeconfig:
# eval $(terraform output kubeconfig)
EOF
}

resource "null_resource" "kubeconfig" {

  provisioner "local-exec" {
    command = <<LOCAL_EXEC
KUBECONFIG="${ var.data_dir}/kubeconfig" \
kubectl config set-cluster cluster-${ var.name } \
  --server=https://${ var.master_elb } \
  --certificate-authority=${ var.ca_pem } &&\
KUBECONFIG="${ var.data_dir}/kubeconfig" \
kubectl config set-credentials admin-${ var.name } \
  --certificate-authority=${ var.ca_pem } \
  --client-key=${ var.admin_key_pem } \
  --client-certificate=${ var.admin-pem } &&\
KUBECONFIG="${ var.data_dir}/kubeconfig" \
kubectl config set-context ${ var.name } \
  --cluster=cluster-${ var.name } \
  --user=admin-${ var.name } &&\
KUBECONFIG="${ var.data_dir}/kubeconfig" \
kubectl config use-context ${ var.name }
LOCAL_EXEC
  }

}
