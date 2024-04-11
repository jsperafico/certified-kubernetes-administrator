# Core Concepts

## Introduction

*Container Orchestrator Solutions*:
- Docker Swarm
- Kubernetes (Developed by Google and now maintained by Cloud Native Computing Foundation)
- Among others

Often cloud providers offer services to automatically manage your Kubernetes cluster, reducing the overhead on big projects:
- Amazon Elastic Container Service
- Azure Kubernetes Service

Orchestrators are responsible to keep your deployments running even in case of failure, 
often restarting in another Virtual Machine within the same replication/scale set. 
Such approach grants reliability.

Usually a cluster is composed by:
- Kubernetes (main/master): installation that will orchestrate your instructions.
- Kubernetes (Worker Node Agents): instances where the instructions will run and provision whatever you requested.

*Record of Intend*:

Kubernetes (Main/Master) will automatically identify when a Kubernetes (Worker Node Agent) fails and 
will automatically provision your intented resources in the lowest consumed and avaiable Kubernetes (Worker Node Agent).

## Installation

### How to have Kubernetes?

1. Use a Cloud Provider (like [Azure](https://azure.microsoft.com/en-us/products/kubernetes-service))
2. [Minikube](https://minikube.sigs.k8s.io/docs/start/) (It is by far, the most stable a widly available)
3. Install & configure from scratch (You will learn an aweful lot during this process)

### How to interact with Kubernetes?

1. Api: God, please no!
2. Gui: Not bad.
3. [Kubectl](https://kubernetes.io/docs/tasks/tools/): It is a necessary evil.

### Minikube

Install [Minikube](https://minikube.sigs.k8s.io/docs/start/) and on Administrative proviledged powershell window:

```powershell
PS > minikube config set cpus 4
# make sure to have at least 4 cores for kubernetes. Otherwise some resources will not run. 

PS > minikube start # It will create and/or start Kubernetes and the underlying VM.
PS > minikube addons list # List all available addons for minikube.
PS > minikube addons enable ingress # Example to install addons.
PS > minikube dashboard # Runs a neat web dashboard to visualize what kubernetes is running.
PS > minikube stop # It will stop Kubernetes and the underlying VM.
PS > minikube delete # It will delete Kubernetes and underlying VM.
```

## How to deal with multiple Kubernetes Configs?

Sure, let's imagine you have multiple kubeconfig files. Those, by the way, contain the necessary connection configuration to
a desired Kubernetes (Main/Master) instance. Now, you have a Kubernetes Cluster in Digital Ocean, Azure and Locally. First,
you have deep pockets, not a clue what are you doing leadning Kubernetes, but I am no one to judge you.

You may have 3 different config files, one per cluster location. While using `kubectl` you can specify what config file you want,
like:

```powershell
PS > kubectl --kubeconfig "${config_directory}\azure-kubeconfig.yaml" get nodes
PS > kubectl --kubeconfig "${config_directory}\digitalocean-kubeconfig.yaml" get nodes
PS > kubectl --kubeconfig "${config_directory}\local-kubeconfig.yaml" get nodes
```

Alternatively, it is possible to have a default config file:

```powershell
PS > cp ${config_directory}\azure-kubeconfig.yaml C:\Users\${your_user}\.kube\config
PS > kubectl get nodes
```

# Containers, Pods and Kubernetes Worker Nodes relationship 

`Pod` is a group representation of one or multiple `container` applications and e.g. volumes that
share the same ip address and are tightly couple. It will always run on a Kubernetes (`Worker Node`).
Lastly, a `Worker Node` can have multiple `Pods`.

```powershell
PS > kubectl get nodes 
# Return list of Kubernetes (Master/Main) and (Worker Node Agents).

PS > kubectl run ${pod-name} --image=${image-name:tag} 
# Register a *Record of Intent* that a Pod should be provisioned under a name using a image.

PS > kubectl get nodes 
# Return all pods within the default or configured namespace.

PS > kubectl exec -it ${pod-name} -- bash
# Switch the context of your current console/terminal to your target pod and make it interactive.

PS > kubectl delete pod ${pod-name}
# Deletes the pod with a given name
```

# Kubernetes Objects

Kubernetes Object is basically a *Record of Intent*. Once you inform to Kubernetes (Master/Main),
the same will ensure that object exists. You can define your Kubernetes Object through `kubectl`
or through a configuration `YAML` file, later to be seen.

```powershell
PS > kubectl run ${pod-name} --image=${image-name:tag} 
# Example of a possible definition of Kubernetes Object.
```

# Kubernetes Architecture

Kubernetes (Master/Main) is composed of:
- Kube Controller Manager: Manage multiple controllers regarding your nodes, like replication, endpoint, service account and tokens.
- Cloud Controller Manager: Interact with the underlying cloud provider.
- Kube Api Server: Kubernetes (Worker Node) will interact with this component. Whatever registered and processed by statements will pass through this.
- etcd: A distributed and high available and reliant Key-Value storage of your related cluster (Master/Main and Worker Nodes) data.
- Kube Scheduler: *Record of Intent* watcher of nodeless pods and assign them to one.

Each Kubernetes (Worker Node Agent) has:
- Kubelet: Agent that makes sure a container is running on a desired pod.
- Kube Proxy: A network proxy which maintains network rules on the host and forward the relevant connections.

## Kube API Server

Any interaction through GUI, API and CLI will target this gateway. Creation and Modification
statements are registred in etcd. Sames goes for information retrival. Heavily reliant on etcd.
Your statements may lead to other components, but they all go through Kube Api Server. Finally, Responsible also by Authentication and Authorization mecanisms.

```powershell
PS > kubectl proxy --port 8080 
# It will expose underlying API of kubernetes through HTTP.
```

[Official documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/)
is a superb source of knowledge while creating you YAML file.

## Kube Scheduler

Receives a *Record of Intent* from Kube Api Server that once wrote the record in etcd. 
It will operate over your *Record of Intent*. Maybe it will leads to create and bind
your statemen to a pod or maybe delete a pod. Depends on wha the record says.

Scheduler will take in consideration to allocate a pod based on:
- required resources
- hardware/software policy constraints
- affinity and anti-affinity
- Data Locality

## Kubelet

Kube Api Server will inform a Kubelet inside a Kubernetes (Worker Node Agent) that a 
*Record of Intent* was registred and the scheduler acknowldges that request by logically allocating
a pod for it. Kubelet with this information will allocate/deallocate resources in the underlaying agent allocating the container.

# YAML way to define Kubernetes Objects

```powershell
PS > kubectl run ${pod-name} --image=${image-name:tag} 
# Example of a possible definition of Kubernetes Object.
```

```yaml
apiVersion: v1 # Api version of Kubernetes (Alpha is disable by default)
kind: Pod # Type of Kubernetes Object you want to create
metadata:
    name: nginx # Unique name for *Record of Intent*
spec:
    containers:
    - name: nginx # Container Name must be unique as well
      image: nginx
```

```powershell
PS > kubectl apply -f "${your-file}.yaml"
# Register Kubernetes Object based on the file.
```

## Multi-Containers Pod

Containers within a Pod share an IP adress and port space, and can find each other via localhost.

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: multicontainer
spec:
    containers:
    - name: nginx
      image: nging
      ports: # Primarily Informational, in the same was as EXPOSE in Dockerfile.
      - containerPort: 8080
    - name: busy
      image: busybox
      command:
      - sleep
      - "3600"
```

With the example above, we will have two containers created in the underlying platform and
logically registred/binded to the same pod.

## Generating YAML manifest from CLI

```powershell
PS > kubectl run nginx --image=nginx --port=80 --dry-run=client -o yaml
```

The argument of `--dry-run=client` will skip the entire run execution and `-o yaml` will output
that statement as a yaml manifest. 

## Kubernetes manifest Command and Args

While describing your yaml, you may have `command` and `args` statements. Those are:
- `command`: The overridable `ENTRYPOINT` that will be ran inside of your container.
- `args`: The overridable `CMD`s that will ran after the `command` inside of your container.

Image `ENTRYPOINT` and `CMD` will have be used if Kubernetes `command` and `args` are not established.

```powershell
kubectl explain pod.spec.containers.command
# Should be able visualize the documentation prior referenced as web doc.
```

# And now?

|[Previous](../README.md)|[Next](../1_workloads_schedulers/README.md)|