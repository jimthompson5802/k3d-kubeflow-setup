#!/bin/bash

docker_repository='registry.hub.docker.com'
dask_image='dsimages/dask_image'
image_tag='v6'
number_workers=3

# launch dask scheduler
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: dask-scheduler
  name: dask-scheduler
  namespace: kubeflow-user
spec:
  selector:
    matchLabels:
      app: dask-scheduler
      component: scheduler
  replicas: 1
  template:
    metadata:
      labels:
        app: dask-scheduler
        component: scheduler
      annotations:
        sidecar.istio.io/inject: "false"
    spec:
      serviceAccount: default-editor
      nodeSelector: {}
      securityContext: {}
      affinity: {}
      tolerations: []
      containers:
      - name: dask-scheduler
        imagePullPolicy: Always
        image: ${docker_repository}/${dask_image}:${image_tag} #name of the image
        args:
          - dask-scheduler
          - --port
          - "8786"
          - --bokeh-port
          - "8787"
        ports:
          - containerPort: 8786
          - containerPort: 8787
        resources:
          limits:
            cpu: "2"
            memory: 1G
          requests:
            cpu: "2"
            memory: 1G
---
apiVersion: v1
kind: Service
metadata:
  name: dask-scheduler
  namespace: kubeflow-user
  labels:
    app: dask-scheduler
    component: scheduler
spec:
  ports:
    - name: dask-scheduler
      appProtocol: tcp
      port: 8786
  selector:
    app: dask-scheduler
    component: scheduler
---
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: add-header
  namespace: kubeflow-user
spec:
  configPatches:
  - applyTo: VIRTUAL_HOST
    match:
      context: SIDECAR_OUTBOUND
      routeConfiguration:
        vhost:
          name: dask-scheduler.kubeflow-user.svc.cluster.local:8786
          route:
            name: default
    patch:
      operation: MERGE
      value:
        request_headers_to_add:
        - append: true
          header:
            key: kubeflow-userid
            value: kubeflow-user
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: dask-scheduler
    component: scheduler
  name: dask-scheduler-ui
  namespace: kubeflow-user
spec:
  ports:
  - name: dask-scheduler-ui
    port: 80
    appProtocol: http
    targetPort: 8787
  selector:
    app: dask-scheduler
    component: scheduler
  sessionAffinity: None
  type: ClusterIP
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: dask-scheduler
  namespace: kubeflow-user
spec:
  gateways:
  - kubeflow/kubeflow-gateway
  hosts:
  - '*'
  http:
  - match:
    - uri:
        prefix: /apps/kubeflow-user/dask/
    rewrite:
      uri: /
    route:
    - destination:
        host: dask-scheduler-ui.kubeflow-user.svc.cluster.local
        port:
          number: 80
    timeout: 300s
EOF

echo "Waiting for start of DASK Scheduler"
try_counter=0
while true
do
  num_ready=`kubectl get -l app=dask-scheduler deploy -o jsonpath='{.items[0].status.readyReplicas}'`
  echo "number ready ${num_ready}"
  if [[ $num_ready -eq 1 ]]
  then
    echo "all ready"
    break
  else
    let "try_counter+=1"
    echo "try ${try_counter}: dask scheduler not ready, waiting"
    sleep 5
  fi
done
echo "DASK Scheduler Ready"

dask_scheduler_ip=`kubectl get pod -l app=dask-scheduler -o jsonpath='{.items[0].status.podIP}'`
echo ">>>DASK Scheduler running on IP Address: ${dask_scheduler_ip}"

# start dask worker pods
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: dask-workers
  name: dask-workers
  namespace: kubeflow-user
spec:
  selector:
    matchLabels:
      app: dask-workers
      component: workers
  replicas: ${number_workers} #number of worker pods
  template:
    metadata:
      labels:
        app: dask-workers
        component: workers
      annotations:
        sidecar.istio.io/inject: "false"
    spec:
      serviceAccount: default-editor
      nodeSelector: {}
      securityContext: {}
      affinity: {}
      tolerations: []
      containers:
      - name: dask-worker
        imagePullPolicy: Always
        image: ${docker_repository}/${dask_image}:${image_tag}
        env: []
        args:
          - dask-worker
          - dask-scheduler.kubeflow-user.svc.cluster.local:8786
          - --nthreads
          - "2"
          - --memory-limit
          - "2g"
          - --no-dashboard
        ports:
          - containerPort: 8789
        resources:
          limits:
            cpu: "12"
            memory: 24G
          requests:
            cpu: "2"
            memory: 2G
EOF

# wait for workers to start
echo "Waiting for DASK Workers to start"
try_counter=0
while true
do
  num_ready=`kubectl get -l app=dask-workers deploy -o jsonpath='{.items[0].status.readyReplicas}'`
  echo "number ready ${num_ready}"
  if [[ $num_ready -eq ${number_workers} ]]
  then
    echo "all ready"
    break
  else
    let "try_counter+=1"
    echo "try ${try_counter}, not all workers ready, waiting"
    sleep 5
  fi
done
echo "DASK Workers ready"
