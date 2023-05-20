.PHONY: init plan apply destroy


init: ## Initiate module and dynamic backend state by account.
	@terraform init

plan:
	@terraform plan \
				-var-file="input.tfvars"
apply:
	@terraform apply \
				-var-file="input.tfvars" \
				--auto-approve
destroy:
	@terraform destroy \
				-var-file="input.tfvars" \
				--auto-approve
