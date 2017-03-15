FROM golang:alpine
MAINTAINER "Denver Williams <denver@ii.coop>"
ENV TERRAFORM_VERSION=0.9.0-beta2
ENV KUBECTL_VERSION=v1.5.2
ENV ARC=amd64
ENV AWS_CONFIG_FILE=/cncf/data/awsconfig
ENV KUBECONFIG=/cncf/data/kubeconfig
# Install AWS CLI + Deps 
RUN apk add --update git bash util-linux wget tar curl build-base jq python py-pip groff less && \
pip install awscli && \
	apk --purge -v del py-pip && \
	rm /var/cache/apk/*


#Install Kubectl
RUN wget -O /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/$ARC/kubectl && \
chmod +x /usr/local/bin/kubectl

# Install Terraform 
RUN wget https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_"${TERRAFORM_VERSION}"_linux_$ARC.zip
RUN unzip terraform*.zip -d /usr/bin


# Install CFSSL
RUN go get -u github.com/cloudflare/cfssl/cmd/cfssl && \
#Add Terraform Modules
go get -u github.com/cloudflare/cfssl/cmd/...

WORKDIR /cncf/data
COPY entrypoint.sh /cncf/
COPY aws /aws/
RUN chmod +x /cncf/entrypoint.sh

ENTRYPOINT ["/cncf/entrypoint.sh"]
CMD ["aws"]