# Workloads and Schedulers


## Labels 

It is a key-value pair aiming to query your components that share the same pair, normally refering
to the same meaning.

```powershell
PS > kubectl label pod nginx env=dev
# This set the key=value pair to the pod named "nginx".

PS > kubectl get pods --show-labels
# List all pods withing the default namespace with the associated labels.

PS > kubectl get pods -l env=dev
# List all pods withing the default namespace filter by the label.

PS > kubectl get pods -l env!=dev
# List all pods withing the default namespace filter by those that doesn't have the label.

PS > kubectl label pod nginx env-
# Will remove the existing env=value pair from the "nginx" pod.
```

## ReplicaSets

Raliable strategy to maintain a given *Record of Intent* always running being fault tolerant.
Related concepts:
- Desired State: What should be go after.
- Current State: How many are running.

```powershell
PS > kubectl get replicaset
```

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
    name: nginx-replica
spec:
    replicas: 3
    selector:
        matchLabels:
            tier: reverse-proxy # equivalent to `PS > kubectl get pods -l tier=reverse-proxy`
    template:
        metadata:
            label:
                tier: reverse-proxy # If any other pods inside your namespace share the same label, when you delete the replicaset, those pods will be deleted as well.
        specc:
            containers:
            - name: nginx
              image: nginx
```

A replicable set should be specified inside of the template. Creation of a replicaset from a existent pod, is not possible.

## Deployment

```powershell
PS > kubectl expain deployment
PS > kubectl get deployment
PS > kubectl rollout history deployment.apps/nginx-deployment
# Will list all revisions

PS > kubectl rollout history deployment.apps/nginx-deployment --revision 1
# Will set state to desired revision
```

When a new deployment happens, Kubernetes automatically generates a new version of adesired
*Record of Intent* and will not automatically delete the previous *Record of Intent*. In this way
you can always rollback to a previous state if you need.

```powershell
PS > kubectl create deployment my-deployment --image=nginx --dry-run=client -o yaml
PS > kubectl create deployment my-deployment --image=nginx --replicas 3 --dry-run=client -o yaml
PS > kubectl set image deployment my-deployment nginx=nginx:1.92 # will generate a versioned state
PS > kubectl scale deployment my-deployment --replicas 10 # It will not generate a versioned state
PS > kubectl rollout undo deployment my-deployment # undo will generate a new version using previous state.
```

The `--record` will write the change cause but it will be deprecated. 
Not sure how to proceed with this.  

## DeamonSet

It is a global service that assures your pod is distributed among all Kubernetes (Worker Node Agents).

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
    name: nginx-deamonset
spec:
    selector:
        matchLabels:
            app: nginx-all-nodes
    template:
        metadata:
            labels:
                app: nginx-all-nodes
        spec:
            containers:
            - name: nginx-pods
              image: nginx
```

```powershell
PS > kubectl get pods -o wide
# Output the pods and related Worker Node allocated to.

PS > kubectl get daemonset
PS > kubectl describe daemonset <name>
```

## Node selector

```powershell
PS > kubectl label node minikube disk=ssd
# You can add a label to a Worker Node as well.
```

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: service-pod
spec:
    containers:
    - name: service-pod
      image: nginx
    nodeSelector:
        disk: ssd
```

By applying the manifest above, you will be deploying only on Kubernetes (Worker Nodes) that has that specific label.

## Node Affinity

It is a set of rules used by the Kube Scheduler to determinate where a pod can be placed. Under `pod.spec.affinity` it can be found as `nodeAffinity` or `podAffinity`. We must be aware
that NodeSelector should be deprecated quite soon-ish.

## Resources and Limits

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: nginx-resource-defined
spec:
    containers:
        - name: nginx-container
          image: nginx
          resources:
            requests:
                memory: "64Mi"
                cpu: "0.5"
            limits:
                memory: "128mi"
                cpu: "1"
```

For Kube Scheduler, it only takes in consideration what you are requesting to provision your pod. The limits are not considered.

## Taint and Tolerations

Taints are barriers to repel pod for a especific Kubernetes (Worker Node Agent).

```powershell
PS > kubectl taint nodes minikube key=value:NoSchedule
# This will create a taint that forbidens pod creation on a Worker Node without a toleration.

PS > kubectl apply -f .\1_workloads_schedulers\6-nginx.tainted.yaml
# Will distribute on Worker Nodes that don't have toleration and those that comply with the specified toleration.

PS > kubectl taint nodes minikube key=value:NoSchedule-
# This will untained the worker node. 

PS > Kubectl explain deployment.spec.template.spec.tolerations
```

# And now?

|[Previous](../0_core_concepts/README.md)|[Next](../2_services_networking/README.md)|