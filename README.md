# Staking Facilities Test Assignment


## Summary:
This is a Terraform project that does the following:
1. Creates a Ubuntu EC2 instance in AWS with 2 network interfaces and a public IP that is auto-assigned as a AWS elastic IP.
2. Installs Python and Ansible on the instance. It is also possible to install Ansible locally and run the following steps on the remote Ec2 instance. But to avoid any issues caused by differing Python or Ansible configuration or settings, this project installs and runs Python and Ansible directly on the instance.
3. Installs Apache2 and creates an Apache webserver.
4. Starts the Apache service and configures it to listen on port 80.
5. Creates a simple html testpage to confirm that the web server is properly set up and running. 


## Required:
1. An AWS account with root privileges.
2. A private key for your AWS account.
3. Terraform installed locally on your instance/ machine (preferably Ubuntu) and [added to ENV/PATH](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
4. It is assumed that your AWS setup does not have any Network ACL rules that may conflict with this setup. For this reason, it may be best to use a brand-new test AWS account.


## Steps to reproduce:
1. Create a directory/ folder in your local machine and copy all the files in this repo into this directory.
2. Copy your AWS private key file into the same directory.
3. Open a terminal window and navigate to this directory.
4. Use your preferred text editor to open and edit the terraform.tfvars file. The only values you **must** change are 'key_name' and 'ssh_key_priv' which are both the name of your AWS private key fileß. The rest of the values can be left as-is. Save and close the file.
5. Initialize Terraform with this command in the terminal: **terraform init --upgrade** (Note that this will upgrade your Terraform installation to the latest version).
6. Run the Terraform plan with this command in the terminal: **terraform plan**
7. Execute the Terraform plan with this command in the terminal: **terraform apply** If you prefer a non-interactive execution, use this command instead **terraform apply --auto-approve**
8. Wait for Terraform to complete its run.
9. In your AWS account, a new EC2 instance has now been created. Check and copy the public IP of the created EC2 instance.
10. In a browser window, type **http://public_ip** to view the sample html test page named 'Dickson Kimani Assignment'. Note that you must use 'http://' not 'https://'
11. If no longer needed, you can undo or delete this setup using this Terraform command in the terminal: **terraform destroy --auto-approve** Or if you prefer a non-interactive execution, use this command instead **terraform destroy --auto-approve**
