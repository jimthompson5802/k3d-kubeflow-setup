#!/bin/bash

#  install kubeflow on a k3d ClusterIssuer

kubeflow_components=(\
  array(kubeflow abcd)
  "istio-system xyz"
)

# function to deploy components and wait for start-up
deploy_component() {

  namespace=$1[0]
  component=$1[1]

  kubectl get pods -n ${namespace}
}


for c in ${kubeflow_components[*]}
do
  echo ${c}

  #deploy_component eval(${c})
done
