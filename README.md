# Kubernetes hello-world

This hello-world app has 2 endpoints:
- '/' which displays an "Hello World!" message with the name of the pod it runs
    into and its current version. It also performs heavy computations every time it is accessed.
- '/health' which provides a basic health check

# Installation

This application is a Python app. It runs smoothly in Python 3.5 and Python 2.7.
To run it, you will need to install its dependencies first:
```
pip install -r ./requirements.txt
```
Then you will be able to launch it:
```
python ./app.py
```
By default, the app listens on port *5000*.

This application can also be served by Passenger + Nginx using WSGI without any change in the code.

# Infrastructure

App is hosted on following domains:
1. https://gigapotential.dev
2. https://www.gigapotential.dev

All GCP infrastructure is managed through terraform in `terraform` directory in `apolloio` GCP Project. There are two subdirectories as follows:
1. `modules`: resuable modules independent of the current project.
2. `apolloio`: Creates cloud resources specifically to run the `k8s-helloworld` app on GKE.

Terrform state is stored in Google Storage Bucket `apolloio-terraform-state`


# Deployment

To deploy a new version of code, there are two high level steps:
1. Build and push new Docker image to `us.gcr.io` repository.
    To build the docker image with tag of `HEAD` commit sha:
   ```
   make docker-build-and-push
   ```
   This will create a new image with URI `us.gcr.io/apolloio/apolloio:${TAG}`

2. Deploy to GKE:
   1. First update k8s manifest to use image with new tag in `kubernetes/deployment.yaml` and commit changes, send PR for review and after merging go to next step.
   2. Pull latest master after merging PR and run:
    ```
    make deploy
    ```
    This is shortcut for obtaining kubeconfig credentials for GKE cluster provisioned using Terraform and then running `kubectl apply -f ./kubernetes`

# Kubernetes for new Engineer

## What is Kubernetes
Kubernetes is a container orchestrator to run containers at scale, also known as `k8s` in short. k8s is declarative through k8s resources (submitted to k8s api-server in json or yaml format from client) - you declare "what" resources you want to run on k8s and then controllers on k8s are in constant reconciliation loop to bring current state of cluster to desired state. A single deployable unit on k8s is a `Pod` which is collection of containers.

Every resource on k8s is managed by one or more controllers - the only purpose of these controllers is to run reconciliation loop - to bring current state of cluster to desired state.

## Resources for apolloio app on GKE
The app hosted on `https://gigapotential.dev` is managed by following k8s resources:
1. `Namespace`: Namespace is a logical contruct enabling multitenancy on single cluster. See [kubernetes/namespace.yaml](./kubernetes/namespace.yaml)
2. `Deployment` : A deployment resource is desired replicas of Pods we wish to run. See [kubernetes/deployment.yaml](./kubernetes/deployment.yaml)
3. `Service`: A Service resources lets you load balance traffic among selected Pods. The Pod selection is done through lables assigned to Pod. See [kuberenetes/service.yaml](./kubernetes/service.yaml)
4. `Ingress`: Lets you expose cluster internal `Service` to external world - we create an Ingress resource and configure it to specifiy which `Service` we want to expose. GKE cluster has a preinstalled controller which on seeing an Ingress resource creates a Load Balancer on GCP and routes traffic to our service. See [kubernetes/ingress.yaml](./kubernetes/ingress.yaml)
5. `HorizontalPodAutoscaler`: An HPA lets us dynamically scale up or scale down our `Deployment` resource based on various metrics like cpu usage, memory usage or any custom metrics. In our app we setup HPA based on CPU usage. See [kubernetes/hpa.yaml](./kubernetes/hpa.yaml)
6. `ManagedCertificate`: This is GKE specific custom resource which lets us provision a [Google managed SSL certificate](https://cloud.google.com/kubernetes-engine/docs/how-to/managed-certs)


# Future Work
The current deployment process is manual which can be automated as follows:

## CI

1. CI for building and pushing new Docker image: This can be done for both feature branches as well as `main`/`master` branch.
2. Kubernetes manifests can be auto applied on PR merge: by setting up a tool like [fluxcd](https://fluxcd.io/) or [argocd](https://argoproj.github.io/argo-cd/) - which tracks Kubernetes manifests on a specific branch on Github repository.
3. CI for auto `terraform plan` and `terraform apply`: The workflow would be is that an engineer would create a PR with terraform changes on which CI will automatically post the output of `terraform plan`. This PR when merged to `master`/`main` branch will then be auto applied by CI.

## Helm Chart

Currently all manifests are defined in `kubenertes` doesn't have templating - imagine if you wish to deploy same app for different environments ('staging', 'prod', 'dev', etc.) and we need ablility to change configuration. For example: it could be smaller replicas in non-prod environvironments, Or passing different environment variables. [Helm chart](http://helm.sh/) can help us achived this

## Disable HTTP

For us to allow user to only access app on HTTPS we can set an annotation on Ingress resource
`kubernetes.io/ingress.allow-http: "false"`

# Demo

## Horizontal Pod Autoscaler Demo

Here's the link to video which shows how Pods scale up from 2 to 4 when load is generated on https://gigapotential.dev using Apache Benchmark tool `ab`:

https://drive.google.com/file/d/13GK7MfcJsqQxZ1xsUEhaDqyjThlPd1cL/view?usp=sharing
