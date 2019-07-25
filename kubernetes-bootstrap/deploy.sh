#!/usr/bin/env bash
#
# This script will take a raw, empty kubernetes and prepare and configure it for our deployments

# It is safe to run many times; the initial serviceaccount/rolebindings configuration is always rerun,
# whether the resources it expects to create are there or not- any errors are ignored. This is fine.

# Helm installations are never re-tried. Nor do we run an upgrade if config changes; this is to protect
# me from myself, really- I'd prefer an upgrade to be an overly manual, overly thought out process

set -ax

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

: "${NAMESPACE:=ori}"
: "${KUBECONFIG:=$DIR/kubeconfig}"

function exists {
    exists_in_namespace ${1} ${NAMESPACE}
}

function exists_in_namespace {
    name=$1
    ns=$2

    helm --tiller-namespace=${ns} get $1 &>/dev/null ; return $?
}

kubectl -n kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller

helm init --service-account=tiller --wait

helm repo add techtest https://charts.jspc.pw
helm repo add influx http://influx-charts.storage.googleapis.com

helm repo update

exists_in_namespace ${NAMESPACE} kube-system || (
    helm install --namespace=${NAMESPACE} --name=${NAMESPACE} stable/magic-namespace --values="${DIR}/magic-namespace/values.yaml" --wait
    sleep 30 # Hack in a wait to let tiller start
)

kubectl create clusterrolebinding ori-tiller --clusterrole cluster-admin --serviceaccount=ori:tiller

set -e # Bail if stuff breaks

# ingress controller
exists nginx || helm --tiller-namespace=${NAMESPACE} install --namespace=${NAMESPACE} --name=nginx stable/nginx-ingress --values="${DIR}/nginx/values.yaml" --wait

# monitoring
exists influxdb || helm --tiller-namespace=${NAMESPACE} install --namespace=${NAMESPACE} stable/influxdb --name influxdb --wait
exists telegraf || helm --tiller-namespace=${NAMESPACE} install --namespace=${NAMESPACE} influx/telegraf-ds --name telegraf --values="${DIR}/tick/telegraf/values.yaml" --wait
exists chronograf || helm --tiller-namespace=${NAMESPACE} install --namespace=${NAMESPACE} stable/chronograf --name chronograf --values="${DIR}/tick/chronograph/values.yaml" --wait

# redis for sine-service
exists redis || helm --tiller-namespace=${NAMESPACE} install --namespace=${NAMESPACE} stable/redis-ha --name redis --wait
