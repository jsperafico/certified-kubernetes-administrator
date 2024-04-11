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



# And now?

|[Previous](../0_core_concepts/README.md)|[Next](../2_services_networking/README.md)|