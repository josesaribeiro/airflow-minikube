#!/bin/bash

BASEDIR=$(dirname "$0")

# Start the minikube cluster
/bin/bash $BASEDIR/start_minikube.sh;

if [[ ! $(which helm) ]]; then
  echo Installing helm which is required for deploying to kubernetes
  curl -LO https://git.io/get_helm.sh
  chmod 700 get_helm.sh
  ./get_helm.sh
  helm init --service-account tiller --upgrade
  rm get_helm.sh
fi

# Apply the tiller service account on the minikube cluster
kubectl apply -f $BASEDIR/../airflow/tiller.yaml
helm dependency update $BASEDIR/../airflow

cat $BASEDIR/../docker/build_docker.sh

exit 0
if [[ ! $(docker images | grep airflow) ]]; then
  sh $BASEDIR/../docker/build_docker.sh;
fi

helm upgrade --install airflow $BASEDIR/../airflow/. --namespace=airflow
kubectl config set-context --current --namespace=airflow
