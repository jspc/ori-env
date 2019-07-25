default: all
all: terraform bootstrap helm

.PHONY: terraform bootstrap helm

terraform:
	cd ./terraform ; terraform plan && terraform apply ; cd -

terraform-ci:
	cd terraform && terraform init && terraform apply -auto-approve

kubernetes-bootstrap/kubeconfig:
	aws s3 cp s3://config-ori-jspc-pw/kubeconfig kubernetes-bootstrap/kubeconfig --endpoint=https://nyc3.digitaloceanspaces.com

kubernetes-bootstrap/tick/chronograph/values.yaml:
	aws s3 cp s3://config-ori-jspc-pw/chronograf-values.yaml kubernetes-bootstrap/tick/chronograph/values.yaml --endpoint=https://nyc3.digitaloceanspaces.com

bootstrap: kubernetes-bootstrap/kubeconfig kubernetes-bootstrap/tick/chronograph/values.yaml
	./kubernetes-bootstrap/deploy.sh

helm:
	true

README.md:
	cat docs/README.md terraform/README.md kubernetes-bootstrap/README.md helm-charts/README.md > README.md
