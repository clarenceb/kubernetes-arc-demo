resourceGroup="AzureArcTest"
arcClusterName="AzureArcAKS"
appClonedRepo="https://github.com/clarenceb/hello_arc"

kubectl cluster-info

echo "Create Cluster-level GitOps-Config for deploying nginx-ingress"
az k8sconfiguration create \
    --name nginx-ingress \
    --cluster-name $arcClusterName \
    --resource-group $resourceGroup \
    --operator-instance-name cluster-mgmt \
    --operator-namespace cluster-mgmt \
    --enable-helm-operator \
    --helm-operator-version="0.6.0" \
    --helm-operator-params="--set helm.versions=v3" \
    --repository-url $appClonedRepo \
    --scope cluster \
    --cluster-type connectedClusters \
    --operator-params="--git-poll-interval 3s --git-readonly --git-path=releases/nginx"

echo "Create Namespace-level GitOps-Config for deploying the 'Hello Arc' application"
az k8sconfiguration create \
    --name hello-arc \
    --cluster-name $arcClusterName \
    --resource-group $resourceGroup \
    --operator-instance-name hello-arc \
    --operator-namespace prod \
    --enable-helm-operator \
    --helm-operator-version="0.6.0" \
    --helm-operator-params="--set helm.versions=v3" \
    --repository-url $appClonedRepo \
    --scope namespace \
    --cluster-type connectedClusters \
    --operator-params="--git-poll-interval 3s --git-readonly --git-path=releases/prod"
