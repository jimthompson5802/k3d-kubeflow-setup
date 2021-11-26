# Notes


## Start scheduler and workers from manifest files

```
kubectl apply -f dask_scheduler.yaml

kubectl apply -f dask_workers.yaml
```

## Bash scripts start/stop scheduler and workers from in-line manifest files

```
# script to launch dask pods (scheduler and workers)
# variables to specify docker registry, image, tag and number of workers
./launch_dask.sh

# example output
deployment.apps/dask-scheduler created
service/dask-scheduler created
envoyfilter.networking.istio.io/add-header created
service/dask-scheduler-ui created
virtualservice.networking.istio.io/dask-scheduler created
Waiting for start of DASK Scheduler
number ready
not all ready, waiting
number ready 1
all ready
DASK Scheduler Ready
>>>DASK Scheduler running on IP Address: 10.42.0.87
deployment.apps/dask-workers created
Waiting for DASK Workers to start
number ready
not all ready, waiting
number ready 6
all ready
DASK Workers ready

```

```
# script to stop dask pods
./stop_dash.sh

# example output
deployment.apps "dask-workers" deleted
deployment.apps "dask-scheduler" deleted
service "dask-scheduler" deleted
service "dask-scheduler-ui" deleted
envoyfilter.networking.istio.io "add-header" deleted
virtualservice.networking.istio.io "dask-scheduler" deleted
```

```
# script to retrieve dask scheduler ip address
./get_scheduler_ip.sh

# example output
>>>DASK Scheduler running on IP Address: 10.42.0.71
```

## Notes
* Still need to work on how to assigned dask workers to nodes. short-term solution is bring up notebook server first, before starting dask workers.  This will force k8s to assign workers to agent nodes as needed.  Otherwise agent nodes take up all of resources on server node, which does not allow notebook server to start.
