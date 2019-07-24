# Ori Env

This repo will generate an environment for my tech test
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
## Kubernetes Bootstrap

This repo uses helm to manage pods and deployments, all of which are configured in `./kubernetes-bootstrap`

Bootstrapping will:
 1. Install helm
 1. Install the helm repo that tech test charts are deployed to
 1. Create, using the magic-namespace chart, a namespace for deployments
 1. Run up some monitoring pods (using the [tick stack](https://www.influxdata.com/time-series-platform/) - an opensource timeseries platform useful for monitoring)

### Requirements

To pull down the `kubeconfig` file for the first time, you will need to install `awscli` and set the following environment variables as per:

```bash
$ pip install awscli     # This may exist in your operating system/ distributions package manager
$ export AWS_ACCESS_KEY_ID=digitalocean_spaces_access_key AWS_SECRET_ACCESS_KEY=digitalocean_spaces_secret_key
```

We use `awscli` to pull down data from the Digital Ocean Space the `kubeconfig` lives in, because Digital Ocean Spaces implement the s3 api- we must set the variables as if they were AWS Keys because that's what the tool uses.

```bash
$ make kubeconfig
```

Will now download the correct kubeconfig, and store it in the local directory. It specifically does **not** store this in `~/.kube` to avoid polluting environments.

Finally, to bootstrap the environment (which is an idempotent-ish task; the steps which aren't idempotent are set to be ignored, which is rather a hack, but good enough for our simple needs), the following command is run:

```bash
$ make bootstrap
```

#### Note

We're also pulling down the chronograf helm overrides file. This file contains secrets and this repo is public. Thus: it's accessible to CI for bootstrapping, and to people with access, but nowhere else.
## Helm Charts

This environment expects applications to deployed via helm, and as such provides tooling to do this. Projects which need to deploy, then, need to:

 1. Register this repo as a submodule under a specific path; and
 1. Load the `Makefile` from `helm-charts/Makefile` into their own

This will allow for CI/CD tasks to deploy applications without having to redefine tasks constantly.

This all may be done, in projects, with:

```bash
$ git submodule add git@github.com/jspc/ori-env .ori-env
```

Then adding the following to the top of your Makefile

```makefile
include .ori-env/helm-charts/Makefile
```
