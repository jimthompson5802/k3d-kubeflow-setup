# Testing of k3d docker-based kubernetes cluster for kubeflow

## References
https://k3d.io
https://github.com/kubeflow/manifests

## Install instructions for k3d
```
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v4.4.7 bash
```

## pre-reqs
Pre-reqs:  `brew install`: `kubectl` and `kustomize` commands on Mac.
```
kustomize version
{Version:kustomize/v4.2.0 GitCommit:d53a2ad45d04b0264bcee9e19879437d851cb778 BuildDate:2021-07-01T00:44:28+01:00 GoOs:darwin GoArch:amd64}

kubectl version
Client Version: version.Info{Major:"1", Minor:"21", GitVersion:"v1.21.2", GitCommit:"092fbfbf53427de67cac1e9fa54aaa09a28371d7", GitTreeState:"clean", BuildDate:"2021-06-16T12:59:11Z", GoVersion:"go1.16.5", Compiler:"gc", Platform:"darwin/amd64"}
Server Version: version.Info{Major:"1", Minor:"21", GitVersion:"v1.21.2+k3s1", GitCommit:"5a67e8dc473f8945e8e181f6f0b0dbbc387f6fca", GitTreeState:"clean", BuildDate:"2021-06-21T20:52:44Z", GoVersion:"go1.16.4", Compiler:"gc", Platform:"linux/amd64"}

```

## clone my fork of kubeflow/manifests repo
```
# clone kubeflow manifest repo

git clone https://github.com/jimthompson5802/manifests.git
```

## create k3d cluster
```

# start a k3d cluster
k3d cluster create kf-cluster

```

## deploy kubeflow components from the downloaded manifest profile

Note: created branch "my_customization" for changes required for my setup.  Run each
`kuztomize`  command one at a time.  This takes 45+ minutes on a mid-2014
MBP with 16GB RAM.

```
# cd to kubeflow/manifest repo
# git checkout "my_customization" branch

# deploy each kubeflow service individually

# cert manager
kustomize build common/cert-manager/cert-manager/base | kubectl apply -f -
kustomize build common/cert-manager/kubeflow-issuer/base | kubectl apply -f -

# istio
kustomize build common/istio-1-9/istio-crds/base | kubectl apply -f -
kustomize build common/istio-1-9/istio-namespace/base | kubectl apply -f -
kustomize build common/istio-1-9/istio-install/base | kubectl apply -f -

# DEX
# fix for auhservice dex pod not starting https://github.com/dexidp/dex/issues/2082#issuecomment-818124478
# manually added specified environment variable to common/dex/base/deployment.yaml
kustomize build common/dex/overlays/istio | kubectl apply -f -


# OIDC Auth service
kustomize build common/oidc-authservice/base | kubectl apply -f -


# knative serving
# run knative-serving/base multiple times to define all resources
kustomize build common/knative/knative-serving/base | kubectl apply -f -
kustomize build common/istio-1-9/cluster-local-gateway/base | kubectl apply -f -

# optional for inference event logging (installed)
kustomize build common/knative/knative-eventing/base | kubectl apply -f -

# kubeflow namespace
kustomize build common/kubeflow-namespace/base | kubectl apply -f -


#kubeflow roles
kustomize build common/kubeflow-roles/base | kubectl apply -f -


#kubeflow istio resources
# this defines kubeflow-gateway
kustomize build common/istio-1-9/kubeflow-istio-resources/base | kubectl apply -f -

# kubeflow pipelines (multi-user) (had to re-run multiple times to ensure proper start up)
# this takes 20+ minutes
# stop/start cluster to allow kubectl command to not hang
kustomize build apps/pipeline/upstream/env/platform-agnostic-multi-user | kubectl apply -f -


# KFServing
kustomize build apps/kfserving/upstream/overlays/kubeflow | kubectl apply -f -


# Katib
kustomize build apps/katib/upstream/installs/katib-with-kubeflow | kubectl apply -f -

# Central Dashboard
kustomize build apps/centraldashboard/upstream/overlays/istio | kubectl apply -f -


# Admission Webhook
kustomize build apps/admission-webhook/upstream/overlays/cert-manager | kubectl apply -f -

# Notebooks
kustomize build apps/jupyter/notebook-controller/upstream/overlays/kubeflow | kubectl apply -f -

# jupyter web app
kustomize build apps/jupyter/jupyter-web-app/upstream/overlays/istio | kubectl apply -f -


# Profiles + KFAM
kustomize build apps/profiles/upstream/overlays/kubeflow | kubectl apply -f -


# Volumes Web app
kustomize build apps/volumes-web-app/upstream/overlays/istio | kubectl apply -f -


# Tensorboard Web App and Controller
kustomize build apps/tensorboard/tensorboards-web-app/upstream/overlays/istio | kubectl apply -f -
kustomize build apps/tensorboard/tensorboard-controller/upstream/overlays/kubeflow | kubectl apply -f -


# TFJob Operator
kustomize build apps/tf-training/upstream/overlays/kubeflow | kubectl apply -f -


# Pytorch Operator
kustomize build apps/pytorch-job/upstream/overlays/kubeflow | kubectl apply -f -

# MPI Operator
kustomize build apps/mpi-job/upstream/overlays/kubeflow | kubectl apply -f -

# MXNet Operator
kustomize build apps/mxnet-job/upstream/overlays/kubeflow | kubectl apply -f -

# xgboost Operator
kustomize build apps/xgboost-job/upstream/overlays/kubeflow | kubectl apply -f -

# kubeflow user namespace
# modified profile name from kubeflow-user-example-com to kubeflow-user
kustomize build common/user-namespace/base | kubectl apply -f -


# check if all components are running, all pods should be in 'Running' state
kubectl get pods -n cert-manager
kubectl get pods -n istio-system
kubectl get pods -n auth
kubectl get pods -n knative-eventing
kubectl get pods -n knative-serving
kubectl get pods -n kubeflow
kubectl get pods -n kubeflow-user

```

## Port forward
After establishing port forwarding, access kubeflow dashboard
`http://localhost:8080`
```
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80

```



## Setp HTTPS (Note for future work)
Reference: setup up https for kubeflow:https://www.civo.com/learn/get-up-and-running-with-kubeflow-on-civo-kubernetes

```
cat <<EOF
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: istio-ingressgateway-certs
  namespace: istio-system
spec:
  commonName: istio-ingressgateway.istio-system.svc
  # Use ipAddresses if your LoadBalancer issues an IP
  ipAddresses:
  - <LoadBalancer IP>
#  # Use dnsNames if your LoadBalancer issues a hostname (eg DNS name from Civo dashboard)
#  dnsNames:
#  - <LoadBalancer HostName>
  isCA: true
  issuerRef:
    kind: ClusterIssuer
    name: kubeflow-self-signing-issuer
  secretName: istio-ingressgateway-certs

```
