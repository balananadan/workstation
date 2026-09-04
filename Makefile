common:
	git pull
	rm -f .terraform/terraform.tfstate

apply: common
	terraform init
	terraform apply -auto-approve


destroy: common
	terraform init
	terraform destroy -auto-approve





