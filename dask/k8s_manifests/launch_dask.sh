KUBEFLOW-USER="<User id>"                        #Put your User id in quotes
export server_url="<docker-registry-url>"  #private docker registry url
export repository="ssdsp-user-${KUBEFLOW-USER}"     #your repository
export image_name="dask"                         #name of the image you want to give it
export version_number="v1"                       #version of the image
export notebook_claimName="workspace-dask-demo"  #name of your workspace volume
export docker-registry-secret="docker-registry-pull-secret" #secret for pulling from private docker-registry

export worker_replicas="3"          #number of worker pods

export scheduler_cpu_limit="24"     #use these as the default values. 24,24, 48G,48G
export scheduler_cpu_request="24"
export scheduler_memory_limit="48G"
export scheduler_memory_request="48G"

export worker_cpu_limit="12"         #use these as the default values.  12,12, 24G,24G
export worker_cpu_request="12"
export worker_memory_limit="24G"
export worker_memory_request="24G"

#scheduler-final.yaml
rm -f scheduler-final.yaml temp.yaml
( echo "cat <<EOF >scheduler-final.yaml";
  cat scheduler-template.yaml;
) >temp.yml
. temp.yml
rm temp.yml

#workers-final.yaml
rm -f workers-final.yaml temp.yaml
( echo "cat <<EOF >workers-final.yaml";
  cat workers-template.yaml;
) >temp.yml
. temp.yml
rm temp.yml

kubectl delete -f scheduler-final.yaml  #to delete existing scheduler and worker pods
kubectl delete -f workers-final.yaml

kubectl apply -f scheduler-final.yaml

# kubectl get pods

kubectl apply -f workers-final.yaml

kubectl get pods
