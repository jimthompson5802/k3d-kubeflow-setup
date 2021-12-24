#!/bin/bash

# suspend the docker Containers
docker pause k3d-kubeflow-serverlb
docker pause k3d-kubeflow-server-0
docker pause k3d-kubeflow-agent-0

