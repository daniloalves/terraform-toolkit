#!/bin/bash

REPOSITORY=$(cat ~/.terraform-toolkit.conf | cut -d= -f2)

echo "What environment? [uat/prod] without 'ezy'"
read environment

echo "What project name?"
read project_name

touch main.tf
touch outputs.tf


create_tf_files(){
    cat > "main.tf" <<EOF
variable "name" {
    type = string
    default = "ezy${environment}-${project_name}"
}
EOF

    cat > "state_backend.tf" <<EOF
terraform {
    backend "s3" {
        bucket = "devops.ezycollect.com.au"
        key    = "terraform_state_backend/${project_name}_${environment}"
        region = "us-west-2"
    }
}
EOF
    echo "Terraform files created!"
}

sqs_tmpl(){
        cat >> "main.tf" <<EOF
module "sqs" {
    source = "git::ssh://git-codecommit.us-west-2.amazonaws.com/v1/repos/terraform-sqs"
    queue_name = var.name
    queue_policy_source_arn = module.sns.sns_arn   
}
EOF
}
create_tf_files
sqs_tmpl

# for module in "$1"; do
#     if [ "$module" == "sqs" ];then
#         echo sqs_tmpl >> main.tf
#     fi
# done
