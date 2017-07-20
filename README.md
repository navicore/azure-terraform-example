Terraform for Azure VNets w/ Bastion
---------

#QUICK START

create a service principal if you haven't already

```console
az ad sp create-for-rbac -n "mycloud-1-sp" --role="Contributor"
```

## set these env vars

```bash
export ARM_SUBSCRIPTION_ID=
export ARM_CLIENT_ID=
export ARM_CLIENT_SECRET=
export ARM_TENANT_ID=
```

## edit

* edit `terraform.tfvars` using `terraform.tfvars.example` file

## run

* remove any `terraform.tfstate` files unless this is a restart

```console
terraform apply
```

## Trouble Shooting

* Sometimes fails on a 'resource group not found' error.  Just restart, ie `terraform apply` and it will recover.

