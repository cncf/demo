resource "null_resource" "kubeconfig" {

  provisioner "local-exec" {
    command = <<LOCAL_EXEC
kubectl config set-cluster cluster-${ var.name } \
  --server=https://${ var.external_fqdn } \
  --certificate-authority=${ var.ca-pem } &&\
kubectl config set-credentials admin-${ var.name } \
  --certificate-authority=${ var.ca-pem } \
  --client-key=${ var.admin-key-pem } \
  --client-certificate=${ var.admin-pem } &&\
kubectl config set-context ${ var.name } \
  --cluster=cluster-${ var.name } \
  --user=admin-${ var.name } &&\
kubectl config use-context ${ var.name }
LOCAL_EXEC
  }

}
