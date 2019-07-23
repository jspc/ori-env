default: all
all: terraform bootstrap helm

.PHONY: terraform bootstrap helm

terraform:
	cd ./terraform ; terraform plan && terraform apply ; cd -

bootstrap:
	true

helm:
	true
