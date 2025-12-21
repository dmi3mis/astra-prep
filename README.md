# Script to prepare vms for Astra Cources.
# env local is for ald pro like AP2301
# tested on ALSE 1.8.4

How to use it

```console

ssh-keygen -t ecdsa -f ~/.ssh/id_ecdsa -N ""

chmod +x pre.sh
./pre.sh


# reboot need to update user group membership and disable astra SE modules 
sudo reboot

terragrunt run --all init 
terragrunt run --all plan
terragrunt run --all apply

chmod +x post.sh
./post.sh

```
