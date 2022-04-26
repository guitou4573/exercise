# export ENV=development

ifdef ENV
export BACKEND_CLI=-backend-config=./state_backend/${ENV}.tfvars
else
export BACKEND_CLI=-backend=false
endif

all: help

.PHONY: help # general help
help:
	@echo "- Help -"
	@grep '^.PHONY: .* #' Makefile | sed 's/\.PHONY: \(.*\) # \(.*\)/\1	: \2/' | expand -t15

.PHONY: tf-validate # Validate terraform plan
tf-validate:
	cd ./terraform \
		&& terraform fmt \
		&& terraform validate

.PHONY: tf-init # [ENV] Initialise terraform plan
tf-init:
	cd ./terraform \
		&& terraform init ${BACKEND_CLI}

.PHONY: tf-plan # [ENV] Plan resources to be updated
tf-plan:
	cd ./terraform \
		&& terraform plan -out plan.a -var-file=./values/${ENV}.tfvars

.PHONY: tf-apply # Apply plan
tf-apply:
	cd ./terraform \
		&& terraform apply plan.a

.PHONY: lambda-build # Build docker image for lambda
lambda-build:
	cd ./healthcheck \
		&& docker build . -t healthcheck:latest

.PHONY: lambda-push # Push docker image for lambda to ECR
lambda-push:
	aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin 873715421885.dkr.ecr.us-west-1.amazonaws.com
	docker tag healthcheck:latest 873715421885.dkr.ecr.us-west-1.amazonaws.com/healthcheck:latest
	docker push 873715421885.dkr.ecr.us-west-1.amazonaws.com/healthcheck:latest