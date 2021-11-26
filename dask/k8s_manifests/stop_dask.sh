#!/bin/bash

# stop dask workers
kubectl delete deploy/dask-workers

# stop dask scheduler
kubectl delete deploy/dask-scheduler
kubectl delete service/dask-scheduler
kubectl delete service/dask-scheduler-ui
kubectl delete envoyfilter/add-header
kubectl delete virtualservice/dask-scheduler
