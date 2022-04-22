
# whoami quick testing

Apply whoami `deployment`, `svc` and `ingress`.

``` bash
kubectl apply -f whoami-deployment.yml
kubectl apply -f whoami-service.yml
kubectl apply -f whoami-ingress.yml
```

Test all is ok :

``` bash
curl http://192.168.144.201/whoami
```
