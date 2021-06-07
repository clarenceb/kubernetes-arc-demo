Arc for Kubernetes Demo
=======================

A simple demo to show Arc enabled clusters with:

1. AKS
2. MicroK8s on your laptop

Azure Arc setup
---------------

Follow steps here: https://github.com/microsoft/azure_arc/blob/master/azure_arc_k8s_jumpstart/docs/onboard_k8s.md

```sh
az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.KubernetesConfiguration

az provider show -n Microsoft.Kubernetes -o table
az provider show -n Microsoft.KubernetesConfiguration -o table

az extension add --name connectedk8s
az extension add --name k8sconfiguration

az group create --name AzureArcTest -l EastUS -o table
```

You can skip the cluster connection to Arc `az connectedk8s connect ...`.

Create a Microk8s cluster
-------------------------

Install [microk8s](https://microk8s.io/) on your laptop or another VM:

```sh
microk8s install
microk8s start
microk8s status --wait-ready
microk8s enable dns
microk8s config > kubeconfig-microk8s
```

Linux:

```sh
export KUBECONFIG=./kubeconfig-microk8s
kubectl cluster-info
```

Windows:

```bat
set KUBECONFIG=.\kubeconfig-microk8s
kubectl cluster-info
```

```sh
# Connect the microk8s cluster to Azure Arc
az connectedk8s connect --name AzureArcMicroK8s --resource-group AzureArcTest
```

Create an AKS cluster
---------------------

Open another terminal window.

Follow these steps to create and connect to an AKS cluster: https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough

```sh
az group create -n arc-demos -n australiaeast
az aks create -g arc-demos -n aks1 --node-count 1 --enable-addons monitoring --generate-ssh-keys
az aks install-cli
az aks get-credentials -g arc-demos -n aks1
kubectl cluster-info

# Connect the AKS cluster to Azure Arc
az connectedk8s connect --name AzureArcAKS --resource-group AzureArcTest
```

GitOps using Helm
-----------------

We'll deploy a NGINX ingress controller and a sample web app using GitOps.

MicroK8s (on Windows, adjust for Linux):

Update git repo in `az_k8sconfig_helm_microk8s.bat` if you plan to fork the `hello_arc` repo.

```cmd
.\az_k8sconfig_helm_microk8s.bat

kubectl get all -n azure-arc

kubectl get all -n prod
kubectl get all -n cluster-mgmt
```

Browse to http://localhost:8081

AKS:

Update git repo in `az_k8sconfig_helm_AKS.sh` if you plan to fork the `hello_arc` repo.

```sh
./az_k8sconfig_helm_AKS.sh

kubectl get all -n azure-arc

kubectl get all -n prod
kubectl get all -n cluster-mgmt

kubectl port-forward service/hello-arc-prod 8080:80 -n prod
```

Browse to http://localhost:8080

Make a code change to the GitOps repo (WSL2):

```sh
# Note: Fork this repo so you can commit changes back to it
git clone https://github.com/clarenceb/hello_arc
cd hello_arc

vim releases/prod/hello-arc.yaml

# Change replica count, env MESSAGE
# Git commit, add, push
```

Observe app changes in both local and AKS clusters:

```sh
kubectl get pod -n azure-arc
kubectl logs config-agent-xxxxxxx-xxxxx config-agent -n azure-arc -f | grep "^{" | jq .
```

Cleanup
-------

Microk8s:

```bat
.\az_k8sconfig_helm_cleanup_microk8s.bat
```

Delete the Microk8s cluster:

```bat
microk8s stop
microk8s uninstall
```

AKS:

```sh
./az_k8sconfig_helm_cleanup_AKS.sh
```

Delete the AKS cluster:

```sh
az aks delete -g arc-demos -n aks1
az group delete -n arc-demos
kubectl config unset aks1
```
