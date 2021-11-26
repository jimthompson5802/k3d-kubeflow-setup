# Notes


* Start scheduler and workers
```
kubectl apply -f dask_scheduler.yaml

kubectl apply -f dask_workers.yaml
```

* Still need to work on how to assigne dask workers to nodes. short-term solution is bring up notebook server first, before starting dask workers.  This will force k8s to assign workers to agent nodes as needed.  Otherwise agent nodes take up all of resources on server node, which does not allow notebook server to start.
