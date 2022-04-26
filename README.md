# Exercise

## Instructions

* The Goal

Using infrastructure as code to set up a hello world web server in AWS/Azure, and write a script for the server health check.

* Must achieve

- You will need an AWS/Azure account for this task. You are expected to use free-tier only.

- You can use any infrastructure as code tool you like.

- The code must be able to run anywhere.

- Provide a script to run health checks periodically and externally.

- Provide documents of the code.

- Automate as much as possible. 

- The code must be stored in a source control tool of your choice and a link must be provided 

## Answer

This plan creates networking dependencies, a VM and a lambda that periodically triggers to verify the health of a service on the VM.

### Lambda dependencies

- Create your own ECR repository. I use `873715421885.dkr.ecr.us-west-1.amazonaws.com/exercise-repo`
- Use `make lambda-build` to build the lambda healthcheck's docker image

### Infrastructure as code

- Adjust target environment settings in `./terraform/state_backend/` and `./terraform/values/` to match your target environment.
- Initialise the plan: `make tf-init`
- You can use `make tf-validate` to confirm the structure of the plan is valid.
- Plan resources creation: `ENV=development make tf-plan`
- Create resources: `ENV=development make tf-apply`
