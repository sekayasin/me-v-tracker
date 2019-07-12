#!/bin/bash

set -ex
set -o pipefail

echo "Declaring environment variables"

check_out_infrastructure_code() {
    echo "Checkout infrastructure code"

    mkdir -p /home/circleci/vof-repo
    git clone -b develop ${VOF_INFRASTRUCTURE_REPO} /home/circleci/vof-repo
}

generate_service_account() {
    touch /home/circleci/vof-repo/shared/account.json
    echo ${SERVICE_ACCOUNT} > /home/circleci/vof-repo/shared/account.json
}

setup_ssl_files() {
  if gcloud auth activate-service-account --key-file=/home/circleci/vof-repo/shared/account.json; then
    gsutil cp gs://${GCLOUD_VOF_BUCKET}/ssl/andela_certificate.crt /home/circleci/vof-repo/shared/andela_certificate.crt
    gsutil cp gs://${GCLOUD_VOF_BUCKET}/ssl/andela_key.key /home/circleci/vof-repo/shared/andela_key.key
  fi
}

initialise_terraform() {
    echo "Initializing terraform"

    pushd /home/circleci/vof-repo/vof
        export TF_VAR_state_path="state/sandbox/terraform.tfstate"
        export TF_VAR_project=${GCLOUD_VOF_PROJECT}
        export TF_VAR_bucket=${GCLOUD_VOF_BUCKET}

        terraform init -backend-config="path=${TF_VAR_state_path}" -backend-config="project=${TF_VAR_project}" -backend-config="bucket=${TF_VAR_bucket}" -var="env_name=sandbox" -var="reserved_env_ip=${SANDBOX_RESERVED_IP}"
    popd
}

destroy_infrastructure() {
    echo "Destroy VOF Application"

    pushd /home/circleci/vof-repo/vof
      touch terraform_output.log
      terraform destroy -force -var="state_path=${TF_VAR_state_path}" -var="project_id=${TF_VAR_project}" \
      -var=vof_disk_image="" -var="bucket=${TF_VAR_bucket}" -var="env_name=sandbox" -var="reserved_env_ip=${SANDBOX_RESERVED_IP}" \
      -var="service_account_email=${SERVICE_ACCOUNT_EMAIL}" -var="bugsnag_key"=${BUGSNAG_KEY} -var="slack_channel=${SLACK_CHANNEL}" \
      -var="slack_webhook_url=${SLACK_CHANNEL_HOOK}" -var="cable_url=${CABLE_URL}"  -var="redis_ip=${REDIS_IP}" \
      -var="user_microservice_api_url=${USER_MICROSERVICE_API_URL}" -var="user_microservice_api_token=${USER_MICROSERVICE_API_TOKEN}" \
      -var="google_storage_access_key_id=${GOOGLE_STORAGE_ACCESS_KEY_ID}" -var="google_storage_secret_access_key=${GOOGLE_STORAGE_SECRET_ACCESS_KEY}" \
      -var="db_backup_notification_token=${DB_BACKUP_NOTIFICATION_TOKEN}" 2>&1 | tee terraform_output.log
    popd
}

main (){
    check_out_infrastructure_code
    generate_service_account
    setup_ssl_files
    initialise_terraform
    destroy_infrastructure
}


main "$@"
