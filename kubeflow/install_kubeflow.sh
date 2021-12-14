#!/bin/bash

kubeflow_manifests_dir=$HOME/Desktop/docker_sandbox/kubeflow-manifests
echo ">>> kubeflow-manifest directory is ${kubeflow_manifests_dir}"

# kubeflow components to install
components=( \
  # cert manager
  common/cert-manager/cert-manager/base \
  common/cert-manager/kubeflow-issuer/base \

  # istio
  common/istio-1-9/istio-crds/base \
  common/istio-1-9/istio-namespace/base \
  common/istio-1-9/istio-install/base \

  #DEX
  common/dex/overlays/istio \

  # OIDC Auth Service
  common/oidc-authservice/base \

  # knative serving
  common/knative/knative-serving/base \
  common/istio-1-9/cluster-local-gateway/base \

  # knative evening for inference event logging
  common/knative/knative-eventing/base \

  # kubeflow namespace
  common/kubeflow-namespace/base \

  # kubeflow roles
  common/kubeflow-roles/base \

  # kubeflow istio resources
  common/istio-1-9/kubeflow-istio-resources/base \

  # kubeflow pipelines
  apps/pipeline/upstream/env/platform-agnostic-multi-user-pns \

  # KFServing
  apps/kfserving/upstream/overlays/kubeflow \

  # Katib
  apps/katib/upstream/installs/katib-with-kubeflow \

  # Central Dashboard
  apps/centraldashboard/upstream/overlays/istio \

  # Admission Controler
  apps/admission-webhook/upstream/overlays/cert-manager \

  # Notebooks
  apps/jupyter/notebook-controller/upstream/overlays/kubeflow \

  # Jupyter web app
  apps/jupyter/jupyter-web-app/upstream/overlays/istio \

  # Profiles + KFAM
  apps/profiles/upstream/overlays/kubeflow \

  # Volumes Web app
  apps/volumes-web-app/upstream/overlays/istio \

  # Tensorboard
  # apps/tensorboard/tensorboards-web-app/upstream/overlays/istio \

  # Training Operator
  # apps/training-operator/upstream/overlays/kubeflow \

  # User Namespace
  common/user-namespace/base \
)


# position in clone of official kubernetes manifest repo with my modificaitons
echo ">>> changing working directory local clone of kubeflow-manifest repo"
pushd ${kubeflow_manifests_dir}

# ensure on the correct branch
echo ">>> checkout branch for my customizations"
git checkout my_customizations

# deploy kubeflow components
echo ">>> deploy kubeflow components"
for c in ${components[*]}
do
  echo ">>> Installing ${c}"
  while ! kustomize build ${c} | kubectl apply -f -; do echo "Retrying to apply resources `date`"; sleep 10; done
done
# go back to prior working directory
popd

echo ">>> kubeflow componenets installed"
echo ">>> execute: 'kubectl get pod -A' to see readiness of components "
echo ">>> it may take 20 to 30 minutes for all components to become ready"
