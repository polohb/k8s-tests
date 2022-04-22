# Deploy a kubernetes cluster with kubespray

## Clone kubespray

``` bash
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray && git checkout release-2.18 && cd ../
```

## Create a python virtual env and use it

``` bash
python3 -m venv venv
source venv/bin/activate
```

## Then in this venv prepapre kubespray

``` bash
cd kubespray 
pip install --upgrade pip
pip3 install -r requirements.txt
```

## Create a new cluster inventory

``` bash
# Copy inventory/sample as inventory/mypvecluste
cp -rfp inventory/sample inventory/mypvecluster

# # Update Ansible inventory file with inventory builder
declare -a IPS=(192.168.144.201 192.168.144.202 192.168.144.203)
CONFIG_FILE=inventory/mypvecluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

# Review and change parameters under inventory/mycluster/group_vars
cat inventory/mypvecluster/group_vars/all/all.yml
cat inventory/mypvecluster/group_vars/k8s_cluster/k8s-cluster.yml

# If needed enable nginx ingress in inventory/mypvecluster/group_vars/k8s_cluster/addons.yml
ingress_nginx_enabled: true

# If needed enable k8s dashboard in inventory/mypvecluster/group_vars/k8s_cluster/addons.yml
dashboard_enabled: true
```

## Deploy Kubespray with Ansible Playbook

``` bash
ansible-playbook -i inventory/mypvecluster/hosts.yaml  --become --become-user=root cluster.yml
```

## Get the config from a master

On a master node as root :

``` bash
cat /etc/kubernetes/admin.conf
```

Copy this content in a `~/.kube/pvecluster.yaml` on your machine.

Edit the `server url` to match a `master name or ip`.

Merge the new kube config :

``` bash
cd ~/.kube
cp config config.back
KUBECONFIG=~/.kube/config:~/.kube/pvecluster.yaml kubectl config view --flatten > /tmp/config 
mv /tmp/config config
cd -
```
