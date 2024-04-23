# Storage

Storage is often represented as Persistent Volumes. Those could be on multiple destinations, from your hostpath up to cloud storage.
Obviously, price and size vary drastically. A user can request storage by providing a Persistent Volume Claim.

Note: If Minikube is running on Hyper-V, you won't be able to see it on your windows. 

```powershell
PS > kubectl apply -f .\4_storage\0-demo.pv.yaml
PS > kubectl describe persistentVolume demo-pv
PS > kubectl apply -f .\4_storage\1-demo.pvclaim.yaml
PS > kubectl describe persistentVolumeClaim demo-pvc
PS > kubectl apply -f .\4_storage\2-demo.yaml
PS > kubectl exec -it nginx -- ls -la /data
PS > kubectl delete -f .\4_storage\2-demo.yaml
PS > kubectl delete -f .\4_storage\1-demo.pvclaim.yaml
PS > kubectl delete -f .\4_storage\0-demo.pv.yaml
```

## ConfigMaps

A approach to avoid duplicated image generation for multiple environments, it is to create different Config Maps.
Those will be mounted over your containers and easily accessible through your application properties solution.
Worth to notice, those configurations are not encrypted by default. So, best to use secrets for sensitive data. 

```powershell
PS > kubectl create configmap demo --from-literal=app.nem=2Gb
PS > kubectl get configmap
PS > kubectl get configmap demo -o yaml
PS > kubectl create configmap demo-dev --from-file=.\4_storage\dev.properties
PS > kubectl get configmap demo-dev -o yaml
PS > kubectl apply -f .\4_storage\3-demo.configmap.yaml
PS > kubectl exec -it nginx-dev --  cat /data/dev.properties
PS > kubectl delete -f .\4_storage\3-demo.configmap.yaml
PS > kubectl delete configmap demo-dev
PS > kubectl delete configmap demo
```

## Volume Security Context

In the same way we can specify a user and group while running our containers. We can establish what group
related to our volume, whenever reading or writing files.

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  name: nginx-dev
spec:
  securityContext:
    runAsUser: 1080
    runAsGroup: 3000
    fsGroup: 2000
  containers:
  - image: nginx:latest  
    name: nginx-dev
    volumeMounts:
    - mountPath: /data
      name: demo
  volumes:
  - name: demo
    configMap:
      name: demo-dev
```

The files inside of /data will have the gourp 2000 instead of 3000.

## Expanded Persistent Volume

Is heavily reliant on your Storage Class used to create your Persistent Volumes. There it should have:

```json
{
    "allowVolumeExpansion": true
}
```

To verify this use:

```powershell
PS > kubectl get storageclass standard -o yaml
```

Once enabled, you can resize your Persistent Volume Claim to whatever you need.
Finally, restart your pod by deleting it and recreating it.

# And now?

|[Previous](../3_security/README.md)|[Next](../5_cluster_architecture_installation_config/README.md)|