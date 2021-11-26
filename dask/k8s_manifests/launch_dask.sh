# KUBEFLOW-USER="<User id>"                        #Put your User id in quotes
# export server_url="<docker-registry-url>"  #private docker registry url
# export repository="ssdsp-user-${KUBEFLOW-USER}"     #your repository
# export image_name="dask"                         #name of the image you want to give it
# export version_number="v1"                       #version of the image
# export notebook_claimName="workspace-dask-demo"  #name of your workspace volume
# export docker-registry-secret="docker-registry-pull-secret" #secret for pulling from private docker-registry
#
# export worker_replicas="3"          #number of worker pods
#
# export scheduler_cpu_limit="24"     #use these as the default values. 24,24, 48G,48G
# export scheduler_cpu_request="24"
# export scheduler_memory_limit="48G"
# export scheduler_memory_request="48G"
#
# export worker_cpu_limit="12"         #use these as the default values.  12,12, 24G,24G
# export worker_cpu_request="12"
# export worker_memory_limit="24G"
# export worker_memory_request="24G"

docker_repository='registry.hub.docker.com'
dask_image='dsimages/dask_image'
image_tag='v6'
number_workers=6

# launch dask scheduler
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: dask-scheduler
  name: dask-scheduler
  namespace: kubeflow-user
  annotations:
    sidecar.istio.io/inject: "false"
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
      protocol: TCP
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
  - name: http
    port: 80
    protocol: TCP
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

# start dask worker pods
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: dask-workers
  name: dask-workers
  namespace: kubeflow-user
  annotations:
    sidecar.istio.io/inject: "false"
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
