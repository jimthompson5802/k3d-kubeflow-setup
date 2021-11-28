# Usage Notes

## Observations on MBP mid-2014(4-core, 8 vcpu), 16GB RAM, SSD >400GB Free
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

## Observation on MBP 2019 (8-core, 16 vcpu), 16GB RAM, SSD > 400GB Free
* Install of kubeflow components went by much quicker, longest duration is for the kubeflow resources.  Took roughly 15 minutes for all pods in kubeflow namespace to achieve `Running` state.  Much of the start-up delay due to first time download of images.
* Able to start up to 5 notebook servers with cpu=2 and memory=1Gi requests.
* CPU utilization on freshly created `k3d` cluster according to MacOS Activity monitor is about 25% to 30%.
* CPU utilization on a freshly created kubeflow according to MacOs Activity monitor is around 100% to 200%.
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
