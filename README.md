# Testing of k3d docker-based kubernetes cluster for kubeflow

## References
* https://k3d.io
* https://github.com/kubeflow/manifests

## Usage observations on MBP mid-2014(4-core, 8 vcpu), 16GB RAM, SSD >400GB Free
* Memory demands significantly less compared to minikf (running in VirtualBox)
* When deploying kubeflow pipeline component, cpu is pegged at close to 700% to 800% for about 20 minutes, best NOT to to run other work during this period.
* Able to stop and restart k3d cluster with `k3d cluster start ...` and `k3d cluster stop ...` commands
* Cpu pegged 700% to 800% when restarting cluster for about 4 or 5 minutes, best not to run other work during this period.
* Before install of kubeflow components, idle k3d cluster about 100% to 200% cpu busy on Mac Activity monitor.
* After install of all Kubeflow components, idle kubeflow cluster shows between 100% to 200% cpu busy on Mac Activity Monitor with overall memory usage moderate, no memory pressure indicator.  Update: after several rounds of stop/start, idle cluster is now using 400% to 500% processor.  Not sure why.  Cluster is still usable for dev/testing.
* first time start up of notebook server about 4 to 5 minutes, mainly due to download of notebook image.  cpu pegged close to 600% to 700% busy  Subsequent new notebooks with same image <1 minute.
* Once notebook server is up and running, response time is good.
* Some intermittent sluggishness in kubeflow dashboard, however, quite usable.
* Intermittent disconnects with port forwarding especially during pod initialization where docker image is downloaded. Work-around: if port-forward command terminated, restart; close web page and reopen kubeflow web page.
* with jupyter notebook server and codeserver notebook active at sametime, encountering insufficient memory issues.  For now need to run only one notebook server at a time.

## Usage observation on MBP 2019 (8-core, 16 vcpu), 16GB RAM, SSD > 400GB Free
* Install of kubeflow components went by much quicker, longest duration is for the kubeflow resources.  Took roughly 15 minutes for all pods in kubeflow namespace to achieve `Running` state.  Much of the start-up delay due to first time download of images.
* Able to start up to 5 notebook servers with cpu=2 and memory=1Gi requests.
* CPU utilization on a freshly created kubeflow according to MacOs Activity monitor is around 300%.
* After running numerous ML workflows that created/deleted pods from a notebook server, very high cpu utilization in an idle cluster.  From MacOs Activity monitor `docker` is using > 1000% cpu.  From within the docker containers for `k3d`, `top` in the `k3d server` and `agent` containers:  `/bin/k3s` using 77% cpu in `server-0` container and only 1% utilization in `agent-0` container.
```
#
# top output from k3d server container
#
Mem: 13080976K used, 216940K free, 358208K shrd, 1016436K buff, 5457960K cached
CPU:  62% usr  16% sys   0% nic  20% idle   0% io   0% irq   0% sirq
Load average: 29.26 22.49 10.45 23/2680 23219
  PID  PPID USER     STAT   VSZ %VSZ %CPU COMMAND
    7     1 0        S    2102m  15%  77% /bin/k3s server
 7133  6950 65532    S     734m   5%   0% /ko-app/controller
  173     7 0        S     826m   6%   0% containerd
 5716     1 0        S     697m   5%   0% /bin/containerd-shim-runc-v2 -namespace k8s.io -id 9a93debc2731b46d344094aa0ccd2cad34a38f3c66c
 9325  9136 0        S    1997m  15%   0% /usr/bin/metacontroller --logtostderr -v=4 --discovery-interval=20s
 6944  6531 65532    S     731m   5%   0% /ko-app/webhook
 9377  8512 1337     S     389m   3%   0% /usr/local/bin/envoy -c etc/istio/proxy/envoy-rev0.json --restart-epoch 0 --drain-time-s 45 --
 9378  8449 1337     S     386m   3%   0% /usr/local/bin/envoy -c etc/istio/proxy/envoy-rev0.json --restart-epoch 0 --drain-time-s 45 --
 5913  5716 999      S    2154m  16%   0% mysqld --datadir /var/lib/mysql/datadir
 8589  8237 1000     S     789m   6%   0% /app/cmd/cainjector/cainjector --v=2 --leader-election-namespace=kube-system
 5291     1 0        S     697m   5%   0% /bin/containerd-shim-runc-v2 -namespace k8s.io -id e889b60627bd7a1805c89bedb1dd969501e46915fce

 #
 # top output from k3d agent container
 #
 Mem: 13105172K used, 192744K free, 357884K shrd, 1024008K buff, 5513096K cached
CPU:  63% usr  20% sys   0% nic  15% idle   0% io   0% irq   0% sirq
Load average: 19.92 20.66 11.64 22/2675 22067
  PID  PPID USER     STAT   VSZ %VSZ %CPU COMMAND
    8     1 0        S     886m   6%   1% /bin/k3s agent
   29     8 0        S     893m   7%   0% containerd
 3335  2799 65532    S     733m   5%   0% /ko-app/webhook
 5465  5177 65532    S     732m   5%   0% /ko-app/autoscaler
 3380  2740 65532    S     728m   5%   0% /ko-app/webhook
 5029  4429 65532    S     736m   5%   0% /ko-app/controller
 2118  1862 65532    S     731m   5%   0% /ko-app/mtchannel_broker
 6418  5959 1337     S     193m   1%   0% /usr/local/bin/envoy -c etc/istio/proxy/envoy-rev0.json --restart-epoch 0 --drain-time-s 45 --
 6742  6608 1337     S     193m   1%   0% /usr/local/bin/envoy -c etc/istio/proxy/envoy-rev0.json --restart-epoch 0 --drain-time-s 45 --
 1545  1193 1000     S     733m   5%   0% /app/cmd/controller/controller --v=2 --cluster-resource-namespace=cert-manager --leader-electi
 3440  2899 0        S     312m   2%   0% /usr/local/bin/envoy -c /etc/envoy.yaml
12894  2936 0        S     462m   3%   0% /bin/metadata_store_server --grpc_port=8080 --mysql_config_database=metadb --mysql_config_host
 3721  3249 65532    S     731m   5%   0% /ko-app/channel_dispatcher
  903   827 65532    S     734m   5%   0% /ko-app/controller
```



## Install instructions for k3d
```
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
```

## pre-reqs
* Docker for Mac
* `brew install`: `kubectl` and `kustomize` commands on Mac.

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

Note: created branch "my_customization" for changes required for my setup. Here is
summary of changes.

```
Jim-MacBook-Pro:jim kubeflow-manifests[524]$ git status
On branch my_customizations
nothing to commit, working tree clean
Jim-MacBook-Pro:jim kubeflow-manifests[525]$ git diff master
diff --git a/common/dex/base/deployment.yaml b/common/dex/base/deployment.yaml
index eca0a30a..a0972dc3 100644
--- a/common/dex/base/deployment.yaml
+++ b/common/dex/base/deployment.yaml
@@ -28,6 +28,11 @@ spec:
         envFrom:
           - secretRef:
               name: dex-oidc-client
+        env:
+          - name: KUBERNETES_POD_NAMESPACE
+            valueFrom:
+              fieldRef:
+                fieldPath: metadata.namespace
       volumes:
       - name: config
         configMap:
diff --git a/common/user-namespace/base/params.env b/common/user-namespace/base/params.env
index 9459383c..d1e3195b 100644
--- a/common/user-namespace/base/params.env
+++ b/common/user-namespace/base/params.env
@@ -1,2 +1,2 @@
 user=user@example.com
-profile-name=kubeflow-user-example-com
+profile-name=kubeflow-user

```


## create k3d cluster
```
# create initial kubeflow k3d cluster
k3d cluster create kubeflow -s 1 -a 1 --k3s-arg "--disable=traefik@server:0"
```

## manage k3d kubeflow Cluster
```
# stop running Cluster
k3d cluster stop kubeflow

# restart a stopped cluster, will take several minutes for all kubeflow services
# to start.
k3d cluster start kubeflow
```

## deploy kubeflow components from the downloaded manifest profile

### install all at load
Note: commented out pytorch, tf-job, mxnet, xgboost
```
while ! kustomize build example | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done

```

To monitor cluster start up
```
while true; do kubectl get pod -A | grep -v Running | wc; sleep 10; done

# When line count goes to 3, everything should be running
```


### install component by component
Run each  `kustomize`  command one at a time.  This takes 45+ minutes on a mid-2014
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
# May need to do `k3d cluster stop/start` to allow kubectl command to not hang
# pns exeuctor required for pipelines, docker executor not supported in k3d environment
kustomize build apps/pipeline/upstream/env/platform-agnostic-multi-user-pns | kubectl apply -f -


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
echo -e "\ncert-manager"; kubectl get pods -n cert-manager
echo -e "\nistio-system"; kubectl get pods -n istio-system
echo -e "\nauth"; kubectl get pods -n auth
echo -e "\nknative-eventing"; kubectl get pods -n knative-eventing
echo -e "\nknative-serving"; kubectl get pods -n knative-serving
echo -e "\nkubeflow"; kubectl get pods -n kubeflow
echo -e "\nkubeflow-user"; kubectl get pods -n kubeflow-user

```

## Port forward
After establishing port forwarding, access kubeflow dashboard
`http://localhost:8080`.  Good enough for local development work for an individual,
not suitable for any other uses.  The default email address is `user@example.com` and the default password is `12341234`.
```
# port forward to kubeflow dashboard
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80 &

# port foward for manually started dask scheduler ui
kubectl port-forward svc/dask-scheduler-ui -n kubeflow-user  9080:80 &

```

## Screenshot of using kubeflow in k3d cluster
### k3d cluster Running
![k3d cluster list](./images/k3d-cluster-list.png)

### Notebook server
![notebook server list](./images/notebook-server-list.png)

![notebook server instance](./images/notebook-server-instance.png)

### Kubeflow pipelines
![pipeline view 1](./images/pipeline-view-1.png)

![pipeline view 2](./images/pipeline-view-2.png)

### DASK Scheduler UI
![dask scheduler status](./images/dask1.png)
![dask worker status](./images/dask2.png)

## Useful commands
### Remove completed kubeflow pipeline pods
```
# Use this to see what pods will be deleted
kubectl get pod  -l workflows.argoproj.io/completed=true --field-selector=status.phase==Succeeded

# to remove the pods
kubectl delete pod  -l workflows.argoproj.io/completed=true --field-selector=status.phase==Succeeded

```

## URL for dockerhub registry
```
registry.hub.docker.com/<organization>/<image_repository>:<tag>
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
