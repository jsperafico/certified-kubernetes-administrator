# Security

Multiple ways to authenticate within your cluster. The Role-Base Access Control is the most common out there.
A Role is a collection of rules that represent a set of permissions.
A RoleBinding is the connection between a Role with one or several Accounts.

## RBAC on a single namespace

The following should exemplify how to provide an Account access to a single Namespace within your cluster. 

```powershell
PS > kubectl create serviceaccount external
PS > kubectl apply -f .\3_security\0-nginx.serviceaccount.yaml
PS > kubectl get pod external-pod -o yaml
PS > kubectl apply -f .\3_security\1-custom.role.yaml
PS > kubectl get role
PS > kubectl describe role pod-reader
PS > kubectl apply -f .\3_security\2-custom.rolebinding.yaml
PS > kubectl get rolebinding
PS > kubectl delete rolebinding external
PS > kubectl delete role pod-reader
PS > kubectl delete -f .\3_security\0-nginx.serviceaccount.yaml
PS > kubectl delete serviceaccount external
```

## Cluster Role and Cluster Role Binding

Do not inform the `namespace` meta attribute while creating a role as seen in `.\3_security\1-custom.role.yaml` file.
Likewise, do not inform `namespace` meta attribute while binding the role as seen in `.\3_security\2-custom.rolebinding.yaml` file.

Through the CLI, the difference lies:

```powershell
PS > kubectl get clusterrole
PS > kubectl get clusterrolebinding
```

## Asymetric Key Encryption

Uses public and private keys to encrypt and decrypt data. When one is used to perform a encryption, other should be used to decrypt.
Same goes the otherway around. To exemplify, use `Git Bash` inside your machine to generate a new key-pair.

In admin mode, plase install openssl:

```powershell
choco install openssl.light
```

Back on normal powershell now:

```powershell
PS > openssl genrsa -out custom.key 2048
PS > MSYS_NO_PATHCONV=1 openssl req -new -key custom.key -out custom.csr -subj "/CN=UserCustom/O=Company"
PS > $base64String = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes("custom.csr"))
PS > $base64String = $base64String -replace "`r|`n"
PS > $file = ".\3_security\3-custom.key.yaml"
PS > $content = Get-Content $file
PS > $oldString = "PLACEHOLDER"
PS > $newString = $base64String
PS > $newContent = $content -replace $oldString, $newString
PS > Set-Content $file $newContent
PS > kubectl apply -f .\3_security\3-custom.key.yaml
PS > kubectl get certificateSigningRequest
PS > kubectl certificate approve custom
PS > kubectl get csr custom -o jsonpath='{.status.certificate}' | ForEach-Object {
    $bytes = [System.Convert]::FromBase64String($_)
    [System.IO.File]::WriteAllBytes("custom.crt", $bytes)
}
PS > kubectl config set-credentials UserCustom --client-certificate=custom.crt --client-key=custom.key
PS > kubectl config set-context custom-context --cluster minikube --user=UserCustom
PS > kubectl apply -f .\3_security\4-usercustom.role.yaml
PS > kubectl apply -f .\3_security\5-usercustom.rolebinding.yaml
PS > kubectl --context=custom-context get pods
PS > kubectl config delete-context custom-context
PS > kubectl delete -f .\3_security\5-usercustom.rolebinding.yaml
PS > kubectl delete -f .\3_security\4-usercustom.role.yaml
PS > kubectl delete -f .\3_security\3-custom.key.yaml
PS > Set-Content $file $content
PS > rm custom.crt,custom.csr,custom.key
```

## Generate a KubeConfig from scratch

```powershell
PS > kubectl config --kubeconfig=base-config set-cluster development --server=https://1.2.3.4
PS > kubectl config --kubeconfig=base-config set-credentials external --username=dev --password=some-password
PS > kubectl config --kubeconfig=base-config set-context dev-external --cluster=development --namespace=frontend --user=external
PS > kubectl config --kubeconfig=base-config view
PS > kubectl config --kubeconfig=base-config view use-context dev-external
```

## Kubernetes Secrets

It is a built in solution for secret management. You can use others like HashiCorp Vault, Azure Key Vault, etc.

```powershell
PS > kubectl get secret
PS > kubectl create secret generic special-password --from-literal=dbpass=Super@Simple!123
PS > kubectl describe secret special-password
PS > kubectl get secret special-password -o yaml
PS > kubectl create secret generic no-prod --from-file=.\3_security\not-prod.properties
PS > kubectl apply -f .\3_security\6-super.notsecret.yaml
PS > kubectl apply -f .\3_security\7-super.secret.yaml
PS > kubectl delete -f .\3_security\7-super.secret.yaml
PS > kubectl delete -f .\3_security\6-super.notsecret.yaml
PS > kubectl delete secret no-prod
PS > kubectl apply -f .\3_security\8-nginx.secretvolume.yaml
PS > kubectl exec -it pod/nginx -- cat /etc/foo/dbpass
PS > kubectl delete -f .\3_security\8-nginx.secretvolume.yaml
PS > kubectl apply -f .\3_security\9-nginx.secretenv.yaml
PS > kubectl exec -it pod/nginx -- sh -c 'echo $SPECIAL_PASSWORD'
PS > kubectl delete -f .\3_security\9-nginx.secretenv.yaml
PS > kubectl delete secret special-password
```

# And now?

|[Previous](../2_services_networking/README.md)|[Next](../4_storage/README.md)|