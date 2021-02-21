#!/bin/bash

gcloud container clusters get-credentials --zone us-central1-a apolloio
CONTEXT=gke_apolloio_us-central1-a_apolloio # is derived based on cluster, region/zone & project name

kubectl config set-context ${CONTEXT}

kubectl apply -f ./kubernetes
