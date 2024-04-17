# Services and Networking

## Services

Kubernetes Service can act as an abstraction which can provide a single IP address and DNS
through which pods can be accessed. It can be:
- NodePort: exposes the service on each Kubernetes Worker Node's IP at a static port. 
- ClusterIP: an internal cluster IP address is asigned to the service and can be only reachable within the cluster.
- LoadBalancer: will deploy an external load balancer outside your Kubernetes Worker Nodes to take care of underlying service. Cloud Controller Manager component in Kubernetes Master will be used to provision the required public IP address.
- ExternalName: 

```powershell
PS > kubectl create deployment nginx --image=nginx:latest --replicas 3 --dry-run=client -o yaml > .\2_services_networking\0-nginx.replicas.yaml
PS > kubectl apply -f .\2_services_networking\0-nginx.replicas.yaml 
PS > kubectl apply -f .\2_services_networking\1-nginx.service.labels.yaml
# This will register your pods with the desired label as endpoints for a given service.

PS > kubectl expose deployment nginx --name nginx-service --port=80 --target-port=80 --dry-run=client -o yaml --type=NodePort
```

Alternatively, you can endlessly create both your service and each endpoint manually per 
Pod you want to target to. It shouldn't be a surprise that this is counter productive.

```yaml
apiVersion: v1
kind: Service
metadata:
    name: nginx-service
spec:
    type: ClusterIP # This is default
    ports:
    - port: 8080
      targetPort: 80
```

```yaml
apiVersion: v1
kind: Endpoints
metadata:
    name: nginx-service #Needs to have the same name as your service.
subsets:
    - addresses:
        - ip: <use the ip from one of desired pod>
    ports:
        - port: 80
```

## Helm

It is one of the package manager for Kubernetes. To install it, begin with
[Chocolatey](https://chocolatey.org/install#install-step1).

```powershell
choco

# Output should be something like this
#Chocolatey v1.2.1
#Please run 'choco -?' or 'choco <command> -?' for help menu.
```

From this point onwards, is up to you to use `minikube kubectl` but I prefer to install
`kubectl` locally through chocolatey:

```powershell
choco install kubernetes-cli
```

Install [helm](https://helm.sh/docs/intro/install/).

```powershell
# As admin
choco install kubernetes-helm

helm version

# Output should be something like this
version.BuildInfo{Version:"v3.14.2", GitCommit:"c309b6f0ff63856811846ce18f3bdc93d2b4d54b", GitTreeState:"clean", GoVersion:"go1.21.7"}
```

Packages are available at [artifacthub.io](https://artifacthub.io), prefer to use bitnami charts.

To install packages, please:

```powershell
PS > helm add jenkins https://charts.jenkins.io
PS > helm repo update
PS > helm install jenkins jenkins/jenkins
PS > helm uninstall jenkins
```

## Ingress

Kubernetes Ingress is a collection of routing rules totally reverse-proxy (tomcat, nginx, traefik) agnostic. 
It will governs how external users access the services running withtin the cluster. Features like Load Balancing,
SSL Termination and Named-based virtual hosting are granted with it.

In minikube you can enable ingress with it's own addon, run the following in powershell admintrator mode:

```powershell
PS > minikube addons enable ingress
```

Then you can inspect what ingresses you have within your cluster, through:

```powershell
PS > kubectl get pods -n ingress-nginx
```

Let's deploy (nginx and tomcat) with the respective two services:

```powershell
PS > kubectl create deployment nginx --image=nginx:latest --replicas 2
PS > kubectl create deployment tomcat --image=tomcat:latest --replicas 2
PS > kubectl expose deployment nginx --name nginx-service --port 80 --target-port 80
PS > kubectl expose deployment tomcat --name tomcat-service --port 80 --target-port 80
PS > kubectl get ingressclass
PS > kubectl apply -f .\2_services_networking\ingress.yaml
PS > kubectl get ingress
PS > kubectl describe ingress name-virtual-host-ingress

# To delete all you have done.
PS > kubectl delete -f .\2_services_networking\ingress.yaml
PS > kubectl delete service nginx-service
PS > kubectl delete service tomcat-service
PS > kubectl delete deployment nginx
PS > kubectl delete deployment tomcat
```

Aside of Ingress Rules, you will need a [Ingress Controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/). 
Minikube already offers to you a pre-installed controller as addon based on nginx.
To access your Ingress controller setup in minikube, perform the following in powershell administrator mode.

```powershell
PS > Add-Content -Path "$env:SystemRoot\System32\drivers\etc\hosts" -Value "$(minikube ip) nginx.internal"
PS > Add-Content -Path "$env:SystemRoot\System32\drivers\etc\hosts" -Value "$(minikube ip) tomcat.internal"
```

Then you can open through your browser [http://nginx.internal/](http://nginx.internal/) or [http://tomcat.internal/](http://tomcat.internal/).

Make sure to delete the entries from your `$env:SystemRoot\System32\drivers\etc\hosts` when they are required anymore.

## User And Service Accounts

Humans will use User Accounts to connect to a Kubernetes Cluster.
Pods and Applications will user Service Accounts to connect to Kubernetes Cluster.

```powershell
PS > kubectl get serviceaccounts --all-namespaces
```

Each container on a pod will store it's secret and certificates related to Kubernetes Cluster
Service Account at `/var/run/secrets/kubernetes.io/serviceaccount`, or it will be shown on
`kubectl describe pod <your pod name>`.

The `default` service account in each namespace get no permissions by default other than the
default api discovery permission that Kubernetes grants to all authenticated principals if Role-Based Access Control (RBAC) is enabled.

```powershell
PS > kubectl create serviceaccount custom-token
PS > kubectl apply -f .\2_services_networking\3-nginx.serviceaccount.yaml
PS > kubectl describe pod nginx
PS > kubectl delete -f .\2_services_networking\3-nginx.serviceaccount.yaml
PS > kubectl delete serviceaccount custom-token
```

## Named Port

Under your container port, you can add a Name to it to easily refer later on while creating services:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    ports:
    - containerPort: 80
      name: custom-http
```

```powershell
PS > kubectl expose pod nginx --port=80 --target-port=custom-http --name nginx-svc
```

# And now?

|[Previous](../1_workloads_schedulers/README.md)|[Next](../3_security/README.md)|