#!/bin/bash

docker_file=${1:-Dockerfile_dask}
image_repository=${2:-dask_image}
image_tag=${3:-latest}
progress=${4:-auto}

docker build --progress=${progress} \
  -t dsimages/${image_repository}:${image_tag} \
  -f ./${docker_file}  . \
  && docker push dsimages/${image_repository}:${image_tag}
