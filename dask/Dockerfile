# Test creating custom image
FROM registry.hub.docker.com/jupyter/datascience-notebook:latest

USER 1000

WORKDIR /app

COPY run_jupyterlab.sh /app

CMD '/app/run_jupyterlab.sh'
