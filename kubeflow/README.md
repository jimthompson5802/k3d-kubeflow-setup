# instructions


## Kubeflow Install

* Download the customized version of `kubeflow/manifests` for running locally.
```
git clone https://github.com/jimthompson5802/manifests.git
```

* Update the `kubeflow_manifests_dir` bash variable in `install_kubeflow.sh` to point to location of clone `kubeflow/maniftests`

* run `install_kubeflow.sh`

## Cluster shutdown
This script first "pauses" the docker containers then issues `k3d cluster stop` command
```
./shutdown_cluster.sh
```

## Cluster restart
```
k3d cluster start kubeflow 
```

## Software versions

### Docker
**Docker Desktop for Mac 4.2.0**.  This version is required because it implements cgroup v1.  Docker Desktop 4.3.0+ implements cgruoup v2, which causes several kubeflow components install to fail in a `k3d` cluster with **too many open files** error.

```
$ docker version

Client:
 Cloud integration: v1.0.20
 Version:           20.10.10
 API version:       1.41
 Go version:        go1.16.9
 Git commit:        b485636
 Built:             Mon Oct 25 07:43:15 2021
 OS/Arch:           darwin/amd64
 Context:           default
 Experimental:      true

Server: Docker Engine - Community
 Engine:
  Version:          20.10.10
  API version:      1.41 (minimum version 1.12)
  Go version:       go1.16.9
  Git commit:       e2f740d
  Built:            Mon Oct 25 07:41:30 2021
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.4.11
  GitCommit:        5b46e404f6b9f661a205e28d59c982d3634148f8
 runc:
  Version:          1.0.2
  GitCommit:        v1.0.2-0-g52b36a2
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0


  $ docker info

  Client:
   Context:    default
   Debug Mode: false
   Plugins:
    buildx: Build with BuildKit (Docker Inc., v0.6.3)
    compose: Docker Compose (Docker Inc., v2.1.1)
    scan: Docker Scan (Docker Inc., 0.9.0)

  Server:
   Containers: 3
    Running: 3
    Paused: 0
    Stopped: 0
   Images: 6
   Server Version: 20.10.10
   Storage Driver: overlay2
    Backing Filesystem: extfs
    Supports d_type: true
    Native Overlay Diff: true
    userxattr: false
   Logging Driver: json-file
   Cgroup Driver: cgroupfs
   Cgroup Version: 1
   Plugins:
    Volume: local
    Network: bridge host ipvlan macvlan null overlay
    Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog
   Swarm: inactive
   Runtimes: io.containerd.runc.v2 io.containerd.runtime.v1.linux runc
   Default Runtime: runc
   Init Binary: docker-init
   containerd version: 5b46e404f6b9f661a205e28d59c982d3634148f8
   runc version: v1.0.2-0-g52b36a2
   init version: de40ad0
   Security Options:
    seccomp
     Profile: default
   Kernel Version: 5.10.47-linuxkit
   Operating System: Docker Desktop
   OSType: linux
   Architecture: x86_64
   CPUs: 8
   Total Memory: 12.68GiB
   Name: docker-desktop
   ID: FMXY:2UTT:27G5:5KNU:KQLG:XLMT:BPX3:ZQGO:TU6U:CO6D:Z27A:7HGB
   Docker Root Dir: /var/lib/docker
   Debug Mode: false
   HTTP Proxy: http.docker.internal:3128
   HTTPS Proxy: http.docker.internal:3128
   Registry: https://index.docker.io/v1/
   Labels:
   Experimental: false
   Insecure Registries:
    127.0.0.0/8
   Live Restore Enabled: false

```

### kubectl
```
$ kubectl version --client

Client Version: version.Info{Major:"1", Minor:"20", GitVersion:"v1.20.13", GitCommit:"2444b3347a2c45eb965b182fb836e1f51dc61b70", GitTreeState:"archive", BuildDate:"2021-11-18T06:58:15Z", GoVersion:"go1.17.3", Compiler:"gc", Platform:"darwin/amd64"}
```

### kustomize
```
$ kustomize version

Version: {KustomizeVersion:3.2.0 GitCommit:a3103f1e62ddb5b696daa3fd359bb6f2e8333b49 BuildDate:2019-09-18T16:26:36Z GoOs:darwin GoArch:amd64}

```

### k3d
```
$ k3d version

k3d version v5.2.1
k3s version v1.21.7-k3s1 (default)
```

## Kubeflow Cluster nodes
```
$ kubectl get node -o wide

NAME                    STATUS   ROLES                  AGE   VERSION        INTERNAL-IP   EXTERNAL-IP   OS-IMAGE   KERNEL-VERSION     CONTAINER-RUNTIME
k3d-kubeflow-server-0   Ready    control-plane,master   23m   v1.21.7+k3s1   172.21.0.3    <none>        Unknown    5.10.47-linuxkit   containerd://1.4.12-k3s1
k3d-kubeflow-agent-0    Ready    <none>                 23m   v1.21.7+k3s1   172.21.0.2    <none>        Unknown    5.10.47-linuxkit   containerd://1.4.12-k3s1

```

## Kubeflow components Status
```
$ kubectl get all -A

NAMESPACE          NAME                                                         READY   STATUS    RESTARTS   AGE
kube-system        pod/metrics-server-86cbb8457f-nt64v                          1/1     Running   0          26m
kube-system        pod/local-path-provisioner-5ff76fc89d-krrxg                  1/1     Running   0          26m
kube-system        pod/coredns-7448499f4d-rmj6w                                 1/1     Running   0          26m
cert-manager       pod/cert-manager-7dd5854bb4-xcz4j                            1/1     Running   0          23m
cert-manager       pod/cert-manager-cainjector-64c949654c-xqtjq                 1/1     Running   0          23m
cert-manager       pod/cert-manager-webhook-6b57b9b886-j5285                    1/1     Running   0          23m
auth               pod/dex-5ddf47d88d-p7wn6                                     1/1     Running   1          23m
istio-system       pod/authservice-0                                            1/1     Running   0          23m
istio-system       pod/istiod-86457659bb-4czpg                                  1/1     Running   0          23m
istio-system       pod/cluster-local-gateway-75cb7c6c88-l4mhf                   1/1     Running   0          22m
istio-system       pod/istio-ingressgateway-79b665c95-sxsz6                     1/1     Running   0          23m
knative-eventing   pod/mt-broker-filter-66d4d77c8b-sd7dd                        1/1     Running   0          22m
knative-eventing   pod/imc-controller-688df5bdb4-l27qb                          1/1     Running   0          22m
knative-eventing   pod/imc-dispatcher-646978d797-fzb6b                          1/1     Running   0          22m
knative-eventing   pod/eventing-webhook-78f897666-p82xv                         1/1     Running   0          22m
kubeflow           pod/metacontroller-0                                         1/1     Running   0          22m
kubeflow           pod/katib-ui-64bb96d5bf-nk96z                                1/1     Running   0          22m
kubeflow           pod/notebook-controller-deployment-75b4f7b578-w9bz7          1/1     Running   0          22m
kubeflow           pod/admission-webhook-deployment-667bd68d94-9nzmh            1/1     Running   0          22m
kubeflow           pod/kfserving-models-web-app-7884f597cf-d9sh2                2/2     Running   0          22m
kubeflow           pod/volumes-web-app-deployment-8589d664cc-499nm              1/1     Running   0          22m
kubeflow           pod/jupyter-web-app-deployment-6f744fbc54-h76tq              1/1     Running   0          22m
kubeflow           pod/ml-pipeline-scheduledworkflow-5db54d75c5-8cxlg           2/2     Running   0          22m
knative-eventing   pod/mt-broker-controller-67c977497-2gttn                     1/1     Running   0          22m
knative-eventing   pod/mt-broker-ingress-5c8dc4b5d7-j2qhk                       1/1     Running   0          22m
knative-eventing   pod/eventing-controller-79895f9c56-4zs5d                     1/1     Running   0          22m
knative-serving    pod/controller-57c545cbfb-x8kr8                              2/2     Running   0          22m
knative-serving    pod/webhook-6fffdc4d78-z6qjt                                 2/2     Running   0          22m
kubeflow           pod/workflow-controller-5cbbb49bd8-92v2t                     2/2     Running   2          22m
kubeflow           pod/ml-pipeline-viewer-crd-68fb5f4d58-6k9qj                  2/2     Running   1          22m
knative-serving    pod/istio-webhook-578b6b7654-5nk8w                           2/2     Running   0          22m
kubeflow           pod/katib-controller-68c47fbf8b-bqdn7                        1/1     Running   0          22m
kubeflow           pod/profiles-deployment-89f7d88b-rhscn                       2/2     Running   0          22m
kubeflow           pod/kfserving-controller-manager-0                           2/2     Running   0          22m
kubeflow           pod/ml-pipeline-ui-5bd8d6dc84-p2k28                          2/2     Running   0          22m
knative-serving    pod/networking-istio-6b88f745c-d8dbw                         2/2     Running   0          22m
knative-serving    pod/autoscaler-5c648f7465-7bsnk                              2/2     Running   0          22m
kubeflow           pod/ml-pipeline-persistenceagent-d6bdc77bd-twzjc             2/2     Running   0          22m
kubeflow           pod/katib-db-manager-6c948b6b76-w4bd9                        1/1     Running   2          22m
knative-serving    pod/activator-7476cc56d4-485ml                               2/2     Running   0          22m
kubeflow           pod/centraldashboard-8fc7d8cc-swqbp                          1/1     Running   0          22m
kubeflow           pod/metadata-envoy-deployment-5b4856dd5-hddvc                1/1     Running   0          22m
kubeflow           pod/katib-mysql-7894994f88-xd6dq                             1/1     Running   0          22m
kubeflow           pod/mysql-f7b9b7dd4-8h5hn                                    2/2     Running   0          22m
kubeflow           pod/kubeflow-pipelines-profile-controller-7b947f4748-jhwzn   1/1     Running   0          22m
kubeflow           pod/minio-5b65df66c9-gsl9s                                   2/2     Running   0          22m
kubeflow           pod/metadata-grpc-deployment-6b5685488-66m7n                 2/2     Running   5          22m
kubeflow           pod/metadata-writer-548bd879bb-vd7sq                         2/2     Running   0          22m
kubeflow           pod/ml-pipeline-8c4b99589-4g9nr                              2/2     Running   3          22m
kubeflow-user      pod/ml-pipeline-ui-artifact-5dd95d555b-zl6h2                 2/2     Running   0          14m
kubeflow           pod/cache-deployer-deployment-79fdf9c5c9-pdptx               2/2     Running   1          22m
kubeflow           pod/cache-server-5bdf4f4457-fgf95                            2/2     Running   0          22m
kubeflow           pod/ml-pipeline-visualizationserver-8476b5c645-9tx6s         2/2     Running   0          22m
kubeflow-user      pod/ml-pipeline-visualizationserver-6b44c6759f-f8bn9         2/2     Running   0          14m

NAMESPACE          NAME                                                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                                                                      AGE
default            service/kubernetes                                     ClusterIP   10.43.0.1       <none>        443/TCP                                                                      27m
kube-system        service/kube-dns                                       ClusterIP   10.43.0.10      <none>        53/UDP,53/TCP,9153/TCP                                                       27m
kube-system        service/metrics-server                                 ClusterIP   10.43.79.252    <none>        443/TCP                                                                      27m
cert-manager       service/cert-manager                                   ClusterIP   10.43.23.152    <none>        9402/TCP                                                                     23m
cert-manager       service/cert-manager-webhook                           ClusterIP   10.43.42.226    <none>        443/TCP                                                                      23m
istio-system       service/istio-ingressgateway                           NodePort    10.43.67.92     <none>        15021:31762/TCP,80:31534/TCP,443:31974/TCP,31400:31201/TCP,15443:30635/TCP   23m
istio-system       service/istiod                                         ClusterIP   10.43.78.80     <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP                                        23m
auth               service/dex                                            NodePort    10.43.12.60     <none>        5556:32000/TCP                                                               23m
istio-system       service/authservice                                    ClusterIP   10.43.255.65    <none>        8080/TCP                                                                     23m
istio-system       service/knative-local-gateway                          ClusterIP   10.43.240.26    <none>        80/TCP                                                                       22m
knative-serving    service/activator-service                              ClusterIP   10.43.203.47    <none>        9090/TCP,8008/TCP,80/TCP,81/TCP                                              22m
knative-serving    service/autoscaler                                     ClusterIP   10.43.87.171    <none>        9090/TCP,8008/TCP,8080/TCP                                                   22m
knative-serving    service/controller                                     ClusterIP   10.43.125.240   <none>        9090/TCP,8008/TCP                                                            22m
knative-serving    service/istio-webhook                                  ClusterIP   10.43.92.160    <none>        9090/TCP,8008/TCP,443/TCP                                                    22m
knative-serving    service/webhook                                        ClusterIP   10.43.155.200   <none>        9090/TCP,8008/TCP,443/TCP                                                    22m
istio-system       service/cluster-local-gateway                          ClusterIP   10.43.142.163   <none>        15020/TCP,80/TCP                                                             22m
knative-eventing   service/broker-filter                                  ClusterIP   10.43.16.247    <none>        80/TCP,9092/TCP                                                              22m
knative-eventing   service/broker-ingress                                 ClusterIP   10.43.14.99     <none>        80/TCP,9092/TCP                                                              22m
knative-eventing   service/eventing-webhook                               ClusterIP   10.43.26.170    <none>        443/TCP                                                                      22m
knative-eventing   service/imc-dispatcher                                 ClusterIP   10.43.191.120   <none>        80/TCP                                                                       22m
kubeflow           service/cache-server                                   ClusterIP   10.43.81.117    <none>        443/TCP                                                                      22m
kubeflow           service/kubeflow-pipelines-profile-controller          ClusterIP   10.43.61.27     <none>        80/TCP                                                                       22m
kubeflow           service/metadata-envoy-service                         ClusterIP   10.43.141.56    <none>        9090/TCP                                                                     22m
kubeflow           service/metadata-grpc-service                          ClusterIP   10.43.131.225   <none>        8080/TCP                                                                     22m
kubeflow           service/minio-service                                  ClusterIP   10.43.93.65     <none>        9000/TCP                                                                     22m
kubeflow           service/ml-pipeline                                    ClusterIP   10.43.83.41     <none>        8888/TCP,8887/TCP                                                            22m
kubeflow           service/ml-pipeline-ui                                 ClusterIP   10.43.56.123    <none>        80/TCP                                                                       22m
kubeflow           service/ml-pipeline-visualizationserver                ClusterIP   10.43.166.54    <none>        8888/TCP                                                                     22m
kubeflow           service/mysql                                          ClusterIP   10.43.86.142    <none>        3306/TCP                                                                     22m
kubeflow           service/workflow-controller-metrics                    ClusterIP   10.43.55.121    <none>        9090/TCP                                                                     22m
kubeflow           service/kfserving-controller-manager-metrics-service   ClusterIP   10.43.11.149    <none>        8443/TCP                                                                     22m
kubeflow           service/kfserving-controller-manager-service           ClusterIP   10.43.6.255     <none>        443/TCP                                                                      22m
kubeflow           service/kfserving-models-web-app                       ClusterIP   10.43.21.65     <none>        80/TCP                                                                       22m
kubeflow           service/kfserving-webhook-server-service               ClusterIP   10.43.42.111    <none>        443/TCP                                                                      22m
kubeflow           service/katib-controller                               ClusterIP   10.43.249.93    <none>        443/TCP,8080/TCP                                                             22m
kubeflow           service/katib-db-manager                               ClusterIP   10.43.42.43     <none>        6789/TCP                                                                     22m
kubeflow           service/katib-mysql                                    ClusterIP   10.43.239.206   <none>        3306/TCP                                                                     22m
kubeflow           service/katib-ui                                       ClusterIP   10.43.147.18    <none>        80/TCP                                                                       22m
kubeflow           service/centraldashboard                               ClusterIP   10.43.63.107    <none>        80/TCP                                                                       22m
kubeflow           service/admission-webhook-service                      ClusterIP   10.43.180.171   <none>        443/TCP                                                                      22m
kubeflow           service/notebook-controller-service                    ClusterIP   10.43.61.244    <none>        443/TCP                                                                      22m
kubeflow           service/jupyter-web-app-service                        ClusterIP   10.43.170.252   <none>        80/TCP                                                                       22m
kubeflow           service/profiles-kfam                                  ClusterIP   10.43.121.113   <none>        8081/TCP                                                                     22m
kubeflow           service/volumes-web-app-service                        ClusterIP   10.43.74.167    <none>        80/TCP                                                                       22m
knative-serving    service/autoscaler-bucket-00-of-01                     ClusterIP   10.43.210.160   <none>        8080/TCP                                                                     17m
kubeflow-user      service/ml-pipeline-visualizationserver                ClusterIP   10.43.194.216   <none>        8888/TCP                                                                     14m
kubeflow-user      service/ml-pipeline-ui-artifact                        ClusterIP   10.43.93.62     <none>        80/TCP                                                                       14m

NAMESPACE          NAME                                                    READY   UP-TO-DATE   AVAILABLE   AGE
kube-system        deployment.apps/metrics-server                          1/1     1            1           27m
kube-system        deployment.apps/local-path-provisioner                  1/1     1            1           27m
kube-system        deployment.apps/coredns                                 1/1     1            1           27m
cert-manager       deployment.apps/cert-manager                            1/1     1            1           23m
cert-manager       deployment.apps/cert-manager-cainjector                 1/1     1            1           23m
cert-manager       deployment.apps/cert-manager-webhook                    1/1     1            1           23m
auth               deployment.apps/dex                                     1/1     1            1           23m
istio-system       deployment.apps/istiod                                  1/1     1            1           23m
knative-eventing   deployment.apps/pingsource-mt-adapter                   0/0     0            0           22m
istio-system       deployment.apps/cluster-local-gateway                   1/1     1            1           22m
istio-system       deployment.apps/istio-ingressgateway                    1/1     1            1           23m
knative-eventing   deployment.apps/mt-broker-filter                        1/1     1            1           22m
knative-eventing   deployment.apps/imc-controller                          1/1     1            1           22m
knative-eventing   deployment.apps/imc-dispatcher                          1/1     1            1           22m
knative-eventing   deployment.apps/eventing-webhook                        1/1     1            1           22m
kubeflow           deployment.apps/katib-ui                                1/1     1            1           22m
kubeflow           deployment.apps/notebook-controller-deployment          1/1     1            1           22m
kubeflow           deployment.apps/admission-webhook-deployment            1/1     1            1           22m
kubeflow           deployment.apps/kfserving-models-web-app                1/1     1            1           22m
kubeflow           deployment.apps/volumes-web-app-deployment              1/1     1            1           22m
kubeflow           deployment.apps/jupyter-web-app-deployment              1/1     1            1           22m
kubeflow           deployment.apps/ml-pipeline-scheduledworkflow           1/1     1            1           22m
knative-eventing   deployment.apps/mt-broker-controller                    1/1     1            1           22m
knative-eventing   deployment.apps/mt-broker-ingress                       1/1     1            1           22m
knative-eventing   deployment.apps/eventing-controller                     1/1     1            1           22m
knative-serving    deployment.apps/controller                              1/1     1            1           22m
knative-serving    deployment.apps/webhook                                 1/1     1            1           22m
kubeflow           deployment.apps/workflow-controller                     1/1     1            1           22m
kubeflow           deployment.apps/ml-pipeline-viewer-crd                  1/1     1            1           22m
knative-serving    deployment.apps/istio-webhook                           1/1     1            1           22m
kubeflow           deployment.apps/katib-controller                        1/1     1            1           22m
kubeflow           deployment.apps/profiles-deployment                     1/1     1            1           22m
kubeflow           deployment.apps/ml-pipeline-ui                          1/1     1            1           22m
knative-serving    deployment.apps/networking-istio                        1/1     1            1           22m
knative-serving    deployment.apps/autoscaler                              1/1     1            1           22m
kubeflow           deployment.apps/ml-pipeline-persistenceagent            1/1     1            1           22m
kubeflow           deployment.apps/katib-db-manager                        1/1     1            1           22m
knative-serving    deployment.apps/activator                               1/1     1            1           22m
kubeflow           deployment.apps/centraldashboard                        1/1     1            1           22m
kubeflow           deployment.apps/metadata-envoy-deployment               1/1     1            1           22m
kubeflow           deployment.apps/katib-mysql                             1/1     1            1           22m
kubeflow           deployment.apps/mysql                                   1/1     1            1           22m
kubeflow           deployment.apps/kubeflow-pipelines-profile-controller   1/1     1            1           22m
kubeflow           deployment.apps/minio                                   1/1     1            1           22m
kubeflow           deployment.apps/metadata-grpc-deployment                1/1     1            1           22m
kubeflow           deployment.apps/metadata-writer                         1/1     1            1           22m
kubeflow           deployment.apps/ml-pipeline                             1/1     1            1           22m
kubeflow-user      deployment.apps/ml-pipeline-ui-artifact                 1/1     1            1           14m
kubeflow           deployment.apps/cache-deployer-deployment               1/1     1            1           22m
kubeflow           deployment.apps/cache-server                            1/1     1            1           22m
kubeflow           deployment.apps/ml-pipeline-visualizationserver         1/1     1            1           22m
kubeflow-user      deployment.apps/ml-pipeline-visualizationserver         1/1     1            1           14m

NAMESPACE          NAME                                                               DESIRED   CURRENT   READY   AGE
kube-system        replicaset.apps/metrics-server-86cbb8457f                          1         1         1       26m
kube-system        replicaset.apps/local-path-provisioner-5ff76fc89d                  1         1         1       26m
kube-system        replicaset.apps/coredns-7448499f4d                                 1         1         1       26m
cert-manager       replicaset.apps/cert-manager-7dd5854bb4                            1         1         1       23m
cert-manager       replicaset.apps/cert-manager-cainjector-64c949654c                 1         1         1       23m
cert-manager       replicaset.apps/cert-manager-webhook-6b57b9b886                    1         1         1       23m
auth               replicaset.apps/dex-5ddf47d88d                                     1         1         1       23m
istio-system       replicaset.apps/istiod-86457659bb                                  1         1         1       23m
knative-eventing   replicaset.apps/pingsource-mt-adapter-79d5b4f9bc                   0         0         0       22m
istio-system       replicaset.apps/cluster-local-gateway-75cb7c6c88                   1         1         1       22m
istio-system       replicaset.apps/istio-ingressgateway-79b665c95                     1         1         1       23m
knative-eventing   replicaset.apps/mt-broker-filter-66d4d77c8b                        1         1         1       22m
knative-eventing   replicaset.apps/imc-controller-688df5bdb4                          1         1         1       22m
knative-eventing   replicaset.apps/imc-dispatcher-646978d797                          1         1         1       22m
knative-eventing   replicaset.apps/eventing-webhook-78f897666                         1         1         1       22m
kubeflow           replicaset.apps/katib-ui-64bb96d5bf                                1         1         1       22m
kubeflow           replicaset.apps/notebook-controller-deployment-75b4f7b578          1         1         1       22m
kubeflow           replicaset.apps/admission-webhook-deployment-667bd68d94            1         1         1       22m
kubeflow           replicaset.apps/kfserving-models-web-app-7884f597cf                1         1         1       22m
kubeflow           replicaset.apps/volumes-web-app-deployment-8589d664cc              1         1         1       22m
kubeflow           replicaset.apps/jupyter-web-app-deployment-6f744fbc54              1         1         1       22m
kubeflow           replicaset.apps/ml-pipeline-scheduledworkflow-5db54d75c5           1         1         1       22m
knative-eventing   replicaset.apps/mt-broker-controller-67c977497                     1         1         1       22m
knative-eventing   replicaset.apps/mt-broker-ingress-5c8dc4b5d7                       1         1         1       22m
knative-eventing   replicaset.apps/eventing-controller-79895f9c56                     1         1         1       22m
knative-serving    replicaset.apps/controller-57c545cbfb                              1         1         1       22m
knative-serving    replicaset.apps/webhook-6fffdc4d78                                 1         1         1       22m
kubeflow           replicaset.apps/workflow-controller-5cbbb49bd8                     1         1         1       22m
kubeflow           replicaset.apps/ml-pipeline-viewer-crd-68fb5f4d58                  1         1         1       22m
knative-serving    replicaset.apps/istio-webhook-578b6b7654                           1         1         1       22m
kubeflow           replicaset.apps/katib-controller-68c47fbf8b                        1         1         1       22m
kubeflow           replicaset.apps/profiles-deployment-89f7d88b                       1         1         1       22m
kubeflow           replicaset.apps/ml-pipeline-ui-5bd8d6dc84                          1         1         1       22m
knative-serving    replicaset.apps/networking-istio-6b88f745c                         1         1         1       22m
knative-serving    replicaset.apps/autoscaler-5c648f7465                              1         1         1       22m
kubeflow           replicaset.apps/ml-pipeline-persistenceagent-d6bdc77bd             1         1         1       22m
kubeflow           replicaset.apps/katib-db-manager-6c948b6b76                        1         1         1       22m
knative-serving    replicaset.apps/activator-7476cc56d4                               1         1         1       22m
kubeflow           replicaset.apps/centraldashboard-8fc7d8cc                          1         1         1       22m
kubeflow           replicaset.apps/metadata-envoy-deployment-5b4856dd5                1         1         1       22m
kubeflow           replicaset.apps/katib-mysql-7894994f88                             1         1         1       22m
kubeflow           replicaset.apps/mysql-f7b9b7dd4                                    1         1         1       22m
kubeflow           replicaset.apps/kubeflow-pipelines-profile-controller-7b947f4748   1         1         1       22m
kubeflow           replicaset.apps/minio-5b65df66c9                                   1         1         1       22m
kubeflow           replicaset.apps/metadata-grpc-deployment-6b5685488                 1         1         1       22m
kubeflow           replicaset.apps/metadata-writer-548bd879bb                         1         1         1       22m
kubeflow           replicaset.apps/ml-pipeline-8c4b99589                              1         1         1       22m
kubeflow-user      replicaset.apps/ml-pipeline-ui-artifact-5dd95d555b                 1         1         1       14m
kubeflow           replicaset.apps/cache-deployer-deployment-79fdf9c5c9               1         1         1       22m
kubeflow           replicaset.apps/cache-server-5bdf4f4457                            1         1         1       22m
kubeflow           replicaset.apps/ml-pipeline-visualizationserver-8476b5c645         1         1         1       22m
kubeflow-user      replicaset.apps/ml-pipeline-visualizationserver-6b44c6759f         1         1         1       14m

NAMESPACE      NAME                                            READY   AGE
istio-system   statefulset.apps/authservice                    1/1     23m
kubeflow       statefulset.apps/metacontroller                 1/1     22m
kubeflow       statefulset.apps/kfserving-controller-manager   1/1     22m

NAMESPACE          NAME                                                     REFERENCE                      TARGETS    MINPODS   MAXPODS   REPLICAS   AGE
knative-eventing   horizontalpodautoscaler.autoscaling/broker-filter-hpa    Deployment/mt-broker-filter    1%/70%     1         10        1          22m
knative-eventing   horizontalpodautoscaler.autoscaling/broker-ingress-hpa   Deployment/mt-broker-ingress   1%/70%     1         10        1          22m
knative-serving    horizontalpodautoscaler.autoscaling/activator            Deployment/activator           1%/100%    1         20        1          22m
knative-serving    horizontalpodautoscaler.autoscaling/webhook              Deployment/webhook             12%/100%   1         5         1          22m
knative-eventing   horizontalpodautoscaler.autoscaling/eventing-webhook     Deployment/eventing-webhook    11%/100%   1         5         1          22m

```
