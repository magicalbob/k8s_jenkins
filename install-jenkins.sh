#!/usr/bin/env bash

unset USE_KIND
# Check if kubectl is available in the system
if kubectl 2>/dev/null >/dev/null; then
  # Check if kubectl can communicate with a Kubernetes cluster
  if kubectl get nodes 2>/dev/null >/dev/null; then
    echo "Kubernetes cluster is available. Using existing cluster."
    export USE_KIND=0
  else
    echo "Kubernetes cluster is not available. Creating a Kind cluster..."
    export USE_KIND=X
  fi
else
  echo "kubectl is not installed. Please install kubectl to interact with Kubernetes."
  export USE_KIND=X
fi

if [ "X${USE_KIND}" == "XX" ]; then
    # Make sure cluster exists if Mac
    if ! kind get clusters 2>&1 | grep -q "kind-jenkins"
    then
      envsubst < kind-config.yaml.template > kind-config.yaml
      kind create cluster --config kind-config.yaml --name kind-jenkins
    fi

    # Make sure create cluster succeeded
    if ! kind get clusters 2>&1 | grep -q "kind-jenkins"
    then
        echo "Creation of cluster failed. Aborting."
        exit 255
    fi
fi

# add metrics
kubectl apply -f https://dev.ellisbs.co.uk/files/components.yaml

# install local storage
kubectl apply -f  local-storage-class.yml

export JENKINS_NAMESPACE=jenkins

# create jenkins namespace, if it doesn't exist
kubectl get ns ${JENKINS_NAMESPACE} 2> /dev/null
if [ $? -eq 1 ]
then
    kubectl create namespace ${JENKINS_NAMESPACE}
fi

# create deployment
kubectl apply -f jenkins.deployment.yml

# sort out persistent volume
if [ "X${USE_KIND}" == "XX" ];then
  NODE_NAME=$(kubectl get nodes |grep control-plane|cut -d\  -f1|head -1)
  export NODE_NAME
  envsubst < jenkins.pv.kind.template > jenkins.pv.yml
else
  NODE_NAME=$(kubectl get nodes | grep -v ^NAME|grep -v control-plane|cut -d\  -f1|head -1)
  export NODE_NAME
  envsubst < jenkins.pv.linux.template > jenkins.pv.yml
  echo mkdir -p "${PWD}/jenkins-data"|ssh -o StrictHostKeyChecking=no "${NODE_NAME}"
fi
kubectl apply -f jenkins.pv.yml

kubectl apply -f jenkins.pvc.yml

# Wait for pod to be running
until kubectl get pod -n ${JENKINS_NAMESPACE} | grep 1/1; do
  sleep 5
done

# Set up port-forward
kubectl port-forward service/jenkins -n jenkins --address 127.0.0.1 40080:80 &
