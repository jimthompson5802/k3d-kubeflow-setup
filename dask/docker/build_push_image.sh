#!/bin/bash

image_tag=${1:-latest}
docker_file=${2:-Dockerfile_dask}
image_repository=${3:-dask_image}
progress=${4:-auto}

docker build --progress=${progress} \
  -t dsimages/${image_repository}:${image_tag} \
  -f ./${docker_file}  . \
  && docker push dsimages/${image_repository}:${image_tag}
