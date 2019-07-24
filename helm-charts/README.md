## Helm Charts

This environment expects applications to deployed via helm, and as such provides tooling to do this. Projects which need to deploy, then, need to:

 1. Register this repo as a submodule under a specific path; and
 1. Load the `Makefile` from `helm-charts/Makefile` into their own

This will allow for CI/CD tasks to deploy applications without having to redefine tasks constantly.

This all may be done, in projects, with:

```bash
$ git submodule add git@github.com:jspc/ori-env .ori-env
```

Then adding the following to the top of your Makefile

```makefile
include .ori-env/helm-charts/Makefile
```
