# Instructions for running DASK in the k3d cluster


## Custom images when
* `registry.hub.docker.com/dsimages/custom_datascience:latest` image used to test building/pushing custom images and starting notebook server in cluster.
* `registry.hub.docker.com/dsimages/dask_image:<tag>` dask notebook server image


## Manual delete of images in k3d
Reference GH [Issue#343](https://github.com/rancher/k3d/issues/343)
```
# exec into k3d server node
docker exec -it k3d-kubeflow-server-0 sh

# once in server container run ctr command for image manipulation
# list images in k3d cluster
ctr image list

# remove specific image 
ctr image rm <image-reference-identifer>

```
