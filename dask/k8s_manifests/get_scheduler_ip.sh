#!/bin/bash

dask_scheduler_ip=`kubectl get pod -l app=dask-scheduler -o jsonpath='{.items[0].status.podIP}'`
echo ">>>DASK Scheduler running on IP Address: ${dask_scheduler_ip}"
