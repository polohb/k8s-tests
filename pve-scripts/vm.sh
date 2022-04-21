#!/bin/bash

fn_create_template () {

  template_id=$1

  # Test VM id is not used
  qm list | tr -s ' ' |  tail -n +2 | cut -d ' ' -f2 | grep "${template_id}" 
  ret=$?
  if [ "$ret" -eq 0 ]; then
    echo "VM ID : $template_id already exist ...."
    return $ret
  fi

  # Create a VM with 2GB RQM + 1 network interface connected to bridge vmbr0   
  qm create "${template_id}" --memory 4096 -cores 2 -sockets 1 --net0 virtio,bridge=vmbr0

  # Import downloaded VM image
  qm importdisk "${template_id}" "$CLOUD_IMAGE" "$STORAGE_TYPE"

  # Associate new virtual disk to the VM
  qm set "${template_id}" --scsihw virtio-scsi-pci --scsi0 "$STORAGE_TYPE":vm-"${template_id}"-disk-0

  # Add a cloud-init disk
  qm set "${template_id}" --ide2 "$STORAGE_TYPE":cloudinit

  # Define the boot disk
  qm set "${template_id}" --boot c --bootdisk scsi0

  # Add a vga interface connected to seial
  qm set "${template_id}" --serial0 socket --vga serial0

  # Transform VM into template
  qm template "${template_id}"
}

prepare_pve_host () {

    # check snippets dir already exists
    pvesm status | grep "snippets" 
    ret=$?

    if [ $ret -ne 0 ]; then
        # add snippets storage
        pvesm add dir snippets --path /snippets
        pvesm set snippets --content snippets
    fi
}

create_snip () {

  cat << EOF > /snippets/snippets/k3s_template.yaml

#cloud-config

# update system
package_update: true
package_upgrade: true

users:
  - default
  - name: debian
    groups: [ wheel , sudo ]
    shell: /bin/bash
    homedir: /home/debian
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh_authorized_keys:
        - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCz7NmQpMMTjMOAmC1ELN7lkCazntCudVK3KIZCMS18OAl1E4ZQEoOZu73408ueh9EFRjlFJ/5X6HFRRzxWy71aBawtf5USI6ROZ+Sb48TpoKNLUFGMQcVbHRzI7tDlz693U9eHbBn6lSg9reO3W5rDIAHTwyuuBYUQh14Ia2InE23Gr3KMwbgW5VY41s0/PwWy38gidDp47QRCXBKlgwk68PlpVwCmBdN51nZe5sJGeChlGV2ewuSE0AcT6Bwa3uW/35fq1R9yp+l7ZUdXjnBLQ3aGkDEJ2IiyL/v+IyxwfuAHqaLXSkIlnEtfBydUx6D+lPI9Ai0NHA7ZR40TeUzZ root@pve
        - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCirWH/lr/ln2ovtbBvHJa/1YCE7KOeEM4YPhS1Ys+dJ0g3kfwiILf9rmbM6ixVBzzxqoMojQfglokVKFOk0XjkPuYGB0zxqBtvVnhiYhQiwUZnyXFYSSDIuo2Mz0F4WAV3dDetVrK4P1zhHXEo8MmvFSo7g0SE5ARC6Cd070QjMqoZ1KmR8tylvL7UkBI9OxVQHeNN/dLIlWfNBT9ANt77I2AGPTsOibpzorigjGMV9Ul1K14WXEvA9Ktz1DY9bebqT1l+G9YI/gst3qN2Hdqng93/mPbi8DS+mgBSVOrR1zloJy5pJZVwJy4rkM+z+fk/IKOmOuGOTVbyEV6D36iFEwbkuMmG0OeCeWaIELFqMqd7ib5FNFrG+FNwrNFP1fVuZgCfd6d4RMYvj1SObobBJtu8bt5x1/FPhvVVILBW0idRg5j9dod8BcObQ2OUZ47UUezj5mbacikcq09dl1W0vT1CsVJ2gmjRLJc7wd6p8m5YHi3Z5l9X4SYz2AFdY4+4Kr4K/1IL9M5qelPhbaNnKKl48J8DT4iMoNQPwPKNcRlKE9zq3nmbDL47jsQ/UV/hoj0Zn/b9QvdMg2iyBWhLK6v56LQ1uSnRXnlELySZDPgJO/pWBt1x7hifY2uFSVo0O//X7FtrC5mWf29SQg2DVOrasOF/x//TqzZESRmwiQ== paul@debian-JL

# install base app
packages:
  - qemu-guest-agent
  - curl 
  - git
  - htop
  - vim
  - gnupg
  - software-properties-common
  - docker.io

runcmd:

  # Rename 
  - hostnamectl set-hostname ${vm_hostname}


final_message: "System configuration done : $UPTIME secondes"

power_state:
  delay: "now"
  mode: reboot
  message: Restqrt System
  timeout: 30
  condition: True



EOF

}


create_vm_from_snippet () {

  template_id=$1
  vm_id=$2
  vm_ip=$3
  vm_gh=$4
  vm_hostname=$5

  # Test VM id is not used
  qm list | tr -s ' ' |  tail -n +2 | cut -d ' ' -f2 | grep "${vm_id}"
  ret=$?
  if [ "$ret" -eq 0 ]; then
    echo "VM ID : $vm_id already exist ...."
    return $ret
  fi


  create_snip "$vm_hostname"

  qm clone "${template_id}" "$vm_id" --name "$vm_hostname"

  qm resize "$vm_id" scsi0 6G

  qm set "$vm_id" --ipconfig0 ip="$vm_ip/24,gw=$vm_gh"

  qm set "$vm_id" --cicustom "user=snippets:snippets/k3s_template.yaml"

  qm start "$vm_id"

}


################# MAIN

# Define Cloud init image
CLOUD_IMAGE=debian-11-generic-amd64.qcow2
CLOUD_IMAGE_URL=https://cloud.debian.org/images/cloud/bullseye/latest/$CLOUD_IMAGE

# Define VM Template ID
TEMPLATE_ID=3000

# Define storqge type
STORAGE_TYPE=local-lvm

prepare_pve_host

# Get the cloud init image
[ ! -f "$CLOUD_IMAGE" ] && wget $CLOUD_IMAGE_URL

fn_create_template $TEMPLATE_ID

# @HOME
create_vm_from_snippet "$TEMPLATE_ID" "201" "192.168.144.201" "192.168.144.1" "node1"
create_vm_from_snippet "$TEMPLATE_ID" "202" "192.168.144.202" "192.168.144.1" "node2"
create_vm_from_snippet "$TEMPLATE_ID" "203" "192.168.144.203" "192.168.144.1" "node3"


###### Install k3s on node

fn_master () {
    curl -sfL https://get.k3s.io | sh -
    sudo cat /var/lib/rancher/k3s/server/node-token
    sudo cp /etc/rancher/k3s/k3s.yaml /tmp
    sudo chmod 755 /tmp/k3s.yaml
}

fn_slave () {
    curl -sfL https://get.k3s.io | K3S_URL=https://192.168.144.201:6443 K3S_TOKEN=XXX sh -
}


fn_merge_kube_config (){
  cp config config.back
  KUBECONFIG=~/.kube/config:~/.kube/k3s.yaml kubectl config view --flatten > /tmp/config 
  mv /tmp/config config
}