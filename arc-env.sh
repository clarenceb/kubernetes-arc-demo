SP_FILE=k8s-arc.demo-sp.json
RG_NAME=Arc-k8s-Clusters

export appId="$(jq -r .appId < $SP_FILE)"
export password="$(jq -r .password < $SP_FILE)"
export tenantId="$(jq -r .tenant < $SP_FILE)"
export resourceGroup="Arc-k8s-Clusters"
export arcClusterName="arc-demo-1"
