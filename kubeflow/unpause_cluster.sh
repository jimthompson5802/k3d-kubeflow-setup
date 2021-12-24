#!/bin/bash

# un-suspend the docker Containers
docker unpause k3d-kubeflow-serverlb
docker unpause k3d-kubeflow-server-0
docker unpause k3d-kubeflow-agent-0

