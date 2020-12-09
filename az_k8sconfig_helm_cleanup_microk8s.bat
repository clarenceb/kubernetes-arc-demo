set resourceGroup="AzureArcTest"
set arcClusterName="AzureArcMicroK8s"

echo "Deleting GitOps Configurations from Azure Arc Kubernetes cluster"
az k8sconfiguration delete --name hello-arc --cluster-name %arcClusterName% --resource-group %resourceGroup% --cluster-type connectedClusters -y
az k8sconfiguration delete --name nginx-ingress --cluster-name %arcClusterName% --resource-group %resourceGroup% --cluster-type connectedClusters -y

echo "Cleaning Kubernetes cluster. You can safely ignore non-exist resources"
kubectl delete ns prod
kubectl delete ns cluster-mgmt

kubectl delete clusterrole cluster-mgmt-helm-cluster-mgmt-helm-operator
kubectl delete clusterrole hello-arc-helm-prod-helm-operator-crd
kubectl delete clusterrole nginx-ingress

kubectl delete clusterrolebinding cluster-mgmt-helm-cluster-mgmt-helm-operator
kubectl delete clusterrolebinding hello-arc-helm-prod-helm-operator
kubectl delete clusterrolebinding nginx-ingress

kubectl delete secret sh.helm.release.v1.azure-arc.v1 -n default
