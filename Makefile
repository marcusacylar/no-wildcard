# Makefile for Policy-as-Code Labs (hard-wired to bad-policy.json)

CONTEST_VERSION=0.47.0
TERRAFORM_VERSION=1.9.5
PLAN_BINARY=tfplan.binary
PLAN_JSON=bad-policy.json

.PHONY: all install_conftest install_terraform plan test clean

# Run everything
all: install_conftest install_terraform plan test

# Install Conftest
install_conftest:
	@echo "Installing Conftest..."
	wget -q https://github.com/open-policy-agent/conftest/releases/download/v$(CONTEST_VERSION)/conftest_$(CONTEST_VERSION)_Linux_x86_64.tar.gz -O conftest.tar.gz
	tar -xzf conftest.tar.gz
	sudo mv conftest /usr/local/bin/
	rm conftest.tar.gz
	conftest --version

# Install Terraform
install_terraform:
	@echo "Installing Terraform..."
	curl -fsSL https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip -o terraform.zip
	unzip terraform.zip
	sudo mv terraform /usr/local/bin/
	rm terraform.zip
	terraform -version

# Always regenerate Terraform plan
plan:
	@echo "Generating Terraform plan..."
	rm -f $(PLAN_BINARY) $(PLAN_JSON)   # Remove old files
	terraform init -input=false
	terraform plan -out=$(PLAN_BINARY) -input=false
	terraform show -json $(PLAN_BINARY) > $(PLAN_JSON)
	@echo "Plan written to $(PLAN_JSON)"

# Run Conftest against bad-policy.json
test:
	@echo "Running Conftest tests on $(PLAN_JSON)..."
	conftest test $(PLAN_JSON) --all-namespaces

# Cleanup everything
clean:
	rm -f $(PLAN_BINARY) $(PLAN_JSON) terraform.zip conftest.tar.gz
	@echo "Cleanup complete!"
