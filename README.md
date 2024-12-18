# Staking Facilities Assignment


## Summary:
This is a Terraform project that does the following:
1. Creates a Ubuntu EC2 instance in AWS with 2 network interfaces and a public IP that is auto-assigned as a AWS elastic IP.
2. Executes an Ansible playbook that does the following steps, all on the remote VM/ instance:
    - Installs Python and Ansible on the instance.
      - Note that it is also possible to install Ansible locally and run the following steps on the remote EC2 instance. But to avoid failures caused by host-specific Python or Ansible configuration settings on the Terraform host, this project directly installs Python and Ansible on the remote instance.
    - Installs Apache2 and creates an Apache webserver.
    - Starts the Apache service and configures it to listen on ports 80 and 443.
    - Creates a simple html testpage that is accessible via the public IP of the EC2 instance. 


## Required:
1. An AWS account with root privileges.
2. A private key for your AWS account.
3. Terraform installed locally on your instance/ machine (preferably Ubuntu) and [added to the ENV/PATH](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
4. It is assumed that your AWS setup does not have any Network ACL rules that may conflict with this setup. For this reason, it may be best to use a brand-new test AWS account.


## Steps to reproduce:
1. Create a directory in your local machine and copy all the files from this repo into this directory. It is important that all the project files are in the same directory.
2. Copy your AWS private key file into the same directory.
3. Open a terminal window and navigate into this directory.
4. Use your preferred text editor to open and edit the terraform.tfvars file. The only value that you **must** repalce is 'Your-AWS-private-key' which is the variable assigned to the 'key_name' and 'ssh_key_priv'. And 'Your-AWS-private-key' is the name of your AWS private key file. The rest of the values can be left as-is. Save and close the terraform.tfvars file.
5. Optional step: Initialize Terraform with this command in the terminal: **terraform init --upgrade** (Note that this will upgrade your Terraform installation to the latest version).
6. Run the Terraform plan with this command in the terminal: **terraform plan**
7. Execute the Terraform plan with this command in the terminal: **terraform apply**
   - If you prefer a non-interactive execution, use this command instead **terraform apply --auto-approve**
8. Wait for the Terraform project to complete its run.
9. In your AWS account, a new EC2 instance has now been created. Check and copy the public IP of the created EC2 instance.
10. In a browser window, enter **http://<public_ip>** or **https://<public_ip>** - of course replace '<public_ip>' with the actual IP from your instance. If using https, ignore the "Page is not secure" warning and proceed. The sample html test page named 'Dickson Kimani Assignment' is displayed.
11. If no longer needed, you can undo or delete this setup using this Terraform command in the terminal: **terraform destroy --auto-approve**
    - Or if you prefer a non-interactive execution, use this command instead **terraform destroy --auto-approve**
