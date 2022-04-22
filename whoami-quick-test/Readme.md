
# whoami quick testing

Apply whoami `deployment`, `svc` and `ingress` : 

``` bash
kubectl apply -f whoami-deployment.yml
kubectl apply -f whoami-service.yml
kubectl apply -f whoami-ingress.yml
```

Test all is ok :

``` bash
curl http://192.168.144.201/whoami
```

Purge whoami test :

``` bash
kubectl delete -f whoami-ingress.yml
kubectl delete -f whoami-service.yml
kubectl delete -f whoami-deployment.yml
```
