# Core Concepts

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

# How to have Kubernetes?

1. Use a Cloud Provider (like [Azure](https://azure.microsoft.com/en-us/products/kubernetes-service))
2. [Minikube](https://minikube.sigs.k8s.io/docs/start/) (It is by far, the most stable a widly available)
3. Install & configure from scratch (You will learn an aweful lot during this process)

# How to interact with Kubernetes?

1. Api: God, please no!
2. Gui: Not bad.
3. [Kubectl](https://kubernetes.io/docs/tasks/tools/): It is a necessary evil.

# How to deal with multiple Kubernetes Configs?

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

# Minikube

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



# And now?

|[Previous](../README.md)|[Next](../1_workloads_schedulers/README.md)|