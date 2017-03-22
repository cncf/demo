#!/usr/bin/env bash
set -e

azure_subscription_id= # Derived from the account after login

askSubscription() {
	az account list -o table
	echo ""
	echo "Please enter the Name of the account you wish to use. If you do not see"
	echo "a valid account in the list press Ctrl+C to abort and create one."
	echo "If you leave this blank we will use the Current account."
	echo -n "> "
	read azure_subscription_id
	if [ "$azure_subscription_id" != "" ]; then
		az account set --subscription $azure_subscription_id
		azure_subscription_id=$(az account show | jq -r .id)
	else
		azure_subscription_id=$(az account show | jq -r .id)
	fi
	ARM_SUBSCRIPTION_ID=$azure_subscription_id
	ARM_TENANT_ID=$(az account show | jq -r .tenantId)
	echo "Using subscription_id: $ARM_SUBSCRIPTION_ID"
	echo "Using tenant_id: $ARM_TENANT_ID"
}

createServicePrincipal() {
	echo "==> Creating service principal"
  CREDS_JSON=$( az ad sp create-for-rbac)
  ARM_TENANT_ID=$( echo ${CREDS_JSON} | jq -r .tenant )
  ARM_CLIENT_ID=$( echo ${CREDS_JSON} | jq -r .appId )
  ARM_CLIENT_SECRET=$( echo ${CREDS_JSON} | jq -r .password )
	if [ $? -ne 0 ]; then
		echo "Error creating service principal: $azure_client_id"
		exit 1
	fi
}

showConfigs() {
  echo ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID
  echo ARM_TENANT_ID=$ARM_TENANT_ID
  echo ARM_CLIENT_ID=$ARM_CLIENT_ID
  echo ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET
}

az login > /dev/null
askSubscription
createServicePrincipal
showConfigs > /data/azure.env
echo "./data/azure.env created"
echo 'sudo chown -R $(whoami):$(whoami) ./data'
