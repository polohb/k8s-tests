
# whoami quick testing

## Apply

Apply whoami `deployment`, `svc` and `ingress` :

``` bash
kubectl apply -f whoami-deployment.yml
kubectl apply -f whoami-service.yml
kubectl apply -f whoami-ingress.yml
```

or apply the All In One version :

``` bash
kubectl apply -f whoami-AIO.yml
```

## Test

Test all is ok :

``` bash
curl http://192.168.144.201/whoami
```

## Delete

Purge whoami test by deleting `deployment`, `svc` and `ingress` :

``` bash
kubectl delete -f whoami-ingress.yml
kubectl delete -f whoami-service.yml
kubectl delete -f whoami-deployment.yml
```

or delete using the All In One version :

``` bash
kubectl delete -f whoami-AIO.yml
```


## Helm test

Add and Install the chart :

``` bash
helm repo add cowboysysop https://cowboysysop.github.io/charts/
helm install my-release cowboysysop/whoami
```

Check pod and svc are running :

``` bash
kubectl get pods
> NAME                                 READY   STATUS    RESTARTS   AGE
> my-release-whoami-78c8799c85-cnbsw   1/1     Running   0          9s
```

``` bash
kubect get svc
> NAME                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
> my-release-whoami   ClusterIP   10.233.21.126   <none>        80/TCP    3m12s
```

Test the chart :

``` bash
export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=whoami,app.kubernetes.io/instance=my-release" -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace default port-forward $POD_NAME 8080:80
```

``` bash
curl http://127.0.0.1:8080/
```

Upgrade replica count using helm :

``` bash
helm upgrade my-release --set replicaCount=2 cowboysysop/whoami
```

Check there is now 2 pod  running :

``` bash
kubectl get pods
> NAME                                 READY   STATUS    RESTARTS   AGE
> my-release-whoami-78c8799c85-cnbsw   1/1     Running   0          9s
> my-release-whoami-78c8799c85-fbbrb   1/1     Running   0          48s
```

Delete the chart :

``` bash
helm uninstall my-release
```