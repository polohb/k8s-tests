
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
