## Terraforming this project

### Initialisation

You will need the following digital ocean variables to hand:
 1. Digital Ocean API token
 1. Digital Ocean spaces access key; and
 1. Digital Ocean spaces secret key

These can be passed to terraform on the cli, or set in the environment as per:

```bash
$ export TF_VAR_spaces_access_key=foo TF_VAR_spaces_secret_key=bar TF_VAR_do_token=baz
```

From here, terraform its self can be initialised

```bash
$ terraform init
```

### Planning, running

To inspect changes, assuming the above has been completed, one may run:

```bash
$ terraform plan
```

Assuming, again, that the output of this command is what one expects, the environment can be run as per:

```bash
$ terraform apply
```

The above `plan` and `apply` step can be performed, from the root of this project, as:

```bash
$ make terraform
```
