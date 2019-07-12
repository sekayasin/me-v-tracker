#!/bin/bash

set -ex
set -o pipefail

echo "Declaring environment variables"
declare_env_variables() {
  DEPLOYMENT_ENVIRONMENT="staging"
  RESERVED_IP=${STAGING_RESERVED_IP}
  REDIS_IP=${STAGING_REDIS_IP}
  CABLE_URL=${STAGING_CABLE_URL}
  PROJECT="VOF-tracker"
  PACKER_IMG_TAG=$(cat ~/vof/workspace/output)
  ANDELA_MICRO_PUBLIC_KEY=${STAGING_ANDELA_MICRO_PUBLIC_KEY}
  LEARNER_MICRO_PUBLIC_KEY=${STAGING_LEARNER_MICRO_PUBLIC_KEY}

  if [ "$CIRCLE_BRANCH" == 'master' ]; then
    DEPLOYMENT_ENVIRONMENT="production"
    RESERVED_IP=${PRODUCTION_RESERVED_IP}
    REDIS_IP=${PRODUCTION_REDIS_IP}
    ANDELA_MICRO_PUBLIC_KEY=${PRODUCTION_ANDELA_MICRO_PUBLIC_KEY}
    LEARNER_MICRO_PUBLIC_KEY=${PRODUCTION_LEARNER_MICRO_PUBLIC_KEY}
    CABLE_URL=${PRODUCTION_CABLE_URL}
    BUGSNAG_KEY=${PRODUCTION_BUGSNAG_KEY}
  fi

  if [ "$CIRCLE_BRANCH" == 'design-v2' ]; then
    DEPLOYMENT_ENVIRONMENT="design-v2"
    RESERVED_IP=${DESIGN_V2_RESERVED_IP}
  fi

  if [[ "$CIRCLE_BRANCH" =~ 'sandbox' ]]; then
    DEPLOYMENT_ENVIRONMENT="sandbox"
    RESERVED_IP=${SANDBOX_RESERVED_IP}
    REDIS_IP=${SANDBOX_REDIS_IP}
    CABLE_URL=${SANDBOX_CABLE_URL}
  fi

  EMOJIS=(":celebrate:"  ":party_dinosaur:"  ":andela:" ":aw-yeah:" ":carlton-dance:" ":partyparrot:" ":dancing-penguin:" ":aww-yeah-remix:" )
  RANDOM=$$$(date +%s)
  EMOJI=${EMOJIS[$RANDOM % ${#EMOJIS[@]} ]}
  COMMIT_LINK="https://github.com/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/commit/${CIRCLE_SHA1}"
  DEPLOYMENT_TEXT="Tag: ${PACKER_IMG_TAG} has just been deployed as the latest ${PROJECT} in ${DEPLOYMENT_ENVIRONMENT}  $COMMIT_LINK "
  DEPLOYMENT_CHANNEL=${SLACK_CHANNEL}
  IMG_TAG="$(git rev-parse --short HEAD)"
  SLACK_DEPLOYMENT_TEXT="Git Commit Tag: <$COMMIT_LINK|${IMG_TAG}> has just been deployed to *${PROJECT}* in *${DEPLOYMENT_ENVIRONMENT}* ${EMOJI}"

}

check_out_infrastructure_code() {
    echo "Checkout infrastructure code"

    mkdir -p /home/circleci/vof-repo
    git clone -b master ${VOF_INFRASTRUCTURE_REPO} /home/circleci/vof-repo
}

generate_service_account() {
    touch /home/circleci/vof-repo/shared/account.json
    echo ${SERVICE_ACCOUNT} > /home/circleci/vof-repo/shared/account.json
}

setup_ssl_files() {
  if gcloud auth activate-service-account --key-file=/home/circleci/vof-repo/shared/account.json; then
    gsutil cp gs://${GCLOUD_VOF_BUCKET}/ssl/andela_certificate.pem /home/circleci/vof-repo/shared/andela_certificate.pem
    gsutil cp gs://${GCLOUD_VOF_BUCKET}/ssl/andela_key.key /home/circleci/vof-repo/shared/andela_key.key
  fi
}

setup_environment_vars() {
  if [ "$DEPLOYMENT_ENVIRONMENT" == "production" ]; then
    PRODUCTION_ENVS=`echo $PRODUCTION_ENVS | cut -d'"' -f2`
    for var in $(echo $PRODUCTION_ENVS | tr "," "\n"); do
      echo ${var/=/: } >> /home/circleci/vof/config/application.yml
    done
  fi

  if [ "$DEPLOYMENT_ENVIRONMENT" == "staging" ]; then
    STAGING_ENVS=`echo $STAGING_ENVS | cut -d'"' -f2`
    for var in $(echo $STAGING_ENVS | tr "," "\n"); do
      echo ${var/=/: } >> /home/circleci/vof/config/application.yml
    done
  fi

  if [ "$DEPLOYMENT_ENVIRONMENT" == "design-v2" ]; then
    DESIGN_V2_ENVS=`echo $DESIGN_V2_ENVS | cut -d'"' -f2`
    for var in $(echo $DESIGN_V2_ENVS | tr "," "\n"); do
      echo ${var/=/: } >> /home/circleci/vof/config/application.yml
    done
  fi
  if [ "$DEPLOYMENT_ENVIRONMENT" == "sandbox" ]; then
    SANDBOX_ENVS=`echo $SANDBOX_ENVS | cut -d'"' -f2`
    for var in $(echo $SANDBOX_ENVS | tr "," "\n"); do
      echo ${var/=/: } >> /home/circleci/vof/config/application.yml
    done
  fi

}


initialise_elk_terraform() {
    echo "Initializing elk terraform"

    pushd /home/circleci/vof-repo/elk-infrastructure
        export TF_VAR_state_path="state/elk-stack/terraform.tfstate"
        export TF_VAR_project=${GCLOUD_VOF_PROJECT}
        export TF_VAR_bucket=${GCLOUD_VOF_BUCKET}

        terraform init -backend-config="path=${TF_VAR_state_path}" -backend-config="project=${TF_VAR_project}" -backend-config="bucket=${TF_VAR_bucket}" -var="reserved_env_ip=${RESERVED_IP}"
    popd
}

build_elk_infrastructure() {
    echo "Building elk infrastructure and deploying it"

    pushd /home/circleci/vof-repo/elk-infrastructure
      touch terraform_output.log

      terraform apply --parallelism=1 -var="elk_reserved_env_ip=${ELK_RESERVED_IP}" -var="elk_service_account_email=${SERVICE_ACCOUNT_EMAIL}" -var="elk_project_id=${GCLOUD_VOF_PROJECT}" -var="elk_bucket=${GCLOUD_VOF_BUCKET}"  2>&1 | tee terraform_output.log
    popd
}

initialise_terraform() {
    echo "Initializing terraform"

    pushd /home/circleci/vof-repo/vof
        export TF_VAR_state_path="state/${DEPLOYMENT_ENVIRONMENT}/terraform.tfstate"
        export TF_VAR_project=${GCLOUD_VOF_PROJECT}
        export TF_VAR_bucket=${GCLOUD_VOF_BUCKET}

        terraform init -backend-config="path=${TF_VAR_state_path}" -backend-config="project=${TF_VAR_project}" -backend-config="bucket=${TF_VAR_bucket}" -var="env_name=${DEPLOYMENT_ENVIRONMENT}" -var="vof_disk_image=${PACKER_IMG_TAG}"  -var="reserved_env_ip=${RESERVED_IP}"
    popd
}

build_infrastructure() {
    echo "Building VOF infrastructure and deploying VOF application"

    pushd /home/circleci/vof-repo/vof
      touch terraform_output.log
      if [ "$DEPLOYMENT_ENVIRONMENT" == "production" ]; then
        terraform apply --parallelism=1 -var="state_path=${TF_VAR_state_path}" \
        -var="project_id=${TF_VAR_project}" -var="bucket=${TF_VAR_bucket}" \
        -var="env_name=${DEPLOYMENT_ENVIRONMENT}" -var="vof_disk_image=${PACKER_IMG_TAG}" \
        -var="reserved_env_ip=${RESERVED_IP}" -var="service_account_email=${SERVICE_ACCOUNT_EMAIL}" \
        -var="max_instances=${PRODUCTION_MAX_INSTANCES}" -var="db_instance_tier=${PRODUCTION_DB_TIER}" \
        -var="slack_channel=${SLACK_CHANNEL}" -var="cable_url=${CABLE_URL}"  \
        -var="bugsnag_key"=${BUGSNAG_KEY}  -var="redis_ip=${REDIS_IP}" \
        -var="slack_webhook_url=${SLACK_CHANNEL_HOOK}" \
        -var="user_microservice_api_url=${USER_MICROSERVICE_API_URL}" \
        -var="user_microservice_api_token=${USER_MICROSERVICE_API_TOKEN}" \
        -var="google_storage_access_key_id=${GOOGLE_STORAGE_ACCESS_KEY_ID}" \
        -var="learner_micro_public_key=${LEARNER_MICRO_PUBLIC_KEY}" \
        -var="andela_micro_public_key=${ANDELA_MICRO_PUBLIC_KEY}" \
        -var="google_storage_secret_access_key=${GOOGLE_STORAGE_SECRET_ACCESS_KEY}" \
        -var="mailgun_api_key=${MAILGUN_API_KEY}" \
        -var="mailgun_domain_name=${MAILGUN_DOMAIN_NAME}" \
        -var="freshchat_token=${FRESHCHAT_TOKEN}" \
        -var="def_storage_class=${DEF_STORAGE_CLASS}" \
        -var="storage_class=${STORAGE_CLASS}" \
        -var="bucket_object_age=${BUCKET_OBJECT_AGE}" \
        -var="db_backup_notification_token=${DB_BACKUP_NOTIFICATION_TOKEN}" 2>&1 | tee terraform_output.log
      else
        terraform apply --parallelism=1 -var="state_path=${TF_VAR_state_path}" \
        -var="project_id=${TF_VAR_project}" -var="bucket=${TF_VAR_bucket}" \
        -var="env_name=${DEPLOYMENT_ENVIRONMENT}" -var="vof_disk_image=${PACKER_IMG_TAG}" \
        -var="reserved_env_ip=${RESERVED_IP}" -var="service_account_email=${SERVICE_ACCOUNT_EMAIL}" \
        -var="slack_channel=${SLACK_CHANNEL}" -var="cable_url=${CABLE_URL}" \
        -var="redis_ip=${REDIS_IP}" -var="slack_webhook_url=${SLACK_CHANNEL_HOOK}" \
        -var="bugsnag_key"=${BUGSNAG_KEY} -var="user_microservice_api_url=${USER_MICROSERVICE_API_URL}" \
        -var="user_microservice_api_token=${USER_MICROSERVICE_API_TOKEN}"  \
        -var="google_storage_access_key_id=${GOOGLE_STORAGE_ACCESS_KEY_ID}" \
        -var="google_storage_secret_access_key=${GOOGLE_STORAGE_SECRET_ACCESS_KEY}" \
        -var="andela_micro_public_key=${ANDELA_MICRO_PUBLIC_KEY}" \
        -var="learner_micro_public_key=${LEARNER_MICRO_PUBLIC_KEY}" \
        -var="mailgun_api_key=${MAILGUN_API_KEY}" \
        -var="mailgun_domain_name=${MAILGUN_DOMAIN_NAME}" \
        -var="freshchat_token=${FRESHCHAT_TOKEN}" \
        -var="def_storage_class=${DEF_STORAGE_CLASS}" \
        -var="storage_class=${STORAGE_CLASS}" \
        -var="bucket_object_age=${BUCKET_OBJECT_AGE}" \
        -var="db_backup_notification_token=${DB_BACKUP_NOTIFICATION_TOKEN}" 2>&1 | tee terraform_output.log
      fi
    popd
}

run_rolling_update() {
  echo "Running rolling update on application"

  # ZONE="$(grep 'zone = ' /home/circleci/vof-repo/vof/terraform_output.log | cut -d' ' -f3)"
  INSTANCE_MANAGER="$(grep 'instance-group-manager = ' /home/circleci/vof-repo/vof/terraform_output.log | cut -d' ' -f3)"
  INSTANCE_TEMPLATE="$(grep 'new-instance-template = ' /home/circleci/vof-repo/vof/terraform_output.log | cut -d' ' -f3)"


  if gcloud auth activate-service-account --key-file=/home/circleci/vof-repo/shared/account.json; then
    gcloud config set project ${GCLOUD_VOF_PROJECT}
    gcloud beta compute instance-groups managed rolling-action start-update ${INSTANCE_MANAGER} --version template=${INSTANCE_TEMPLATE} --max-surge 2 --max-unavailable 1 --zone europe-west1-b --min-ready 3m
  fi
}

notify_vof_team_via_slack() {
  echo "Sending success message to slack"

  curl -X POST --data-urlencode \
  "payload={\"channel\": \"${DEPLOYMENT_CHANNEL}\", \"username\": \"DeployNotification\", \"text\": \"${SLACK_DEPLOYMENT_TEXT}\", \"icon_emoji\": \":rocket:\"}" \
  "${SLACK_CHANNEL_HOOK}"
}

main() {
  echo "Deployment script invoked at $(date)" >> /tmp/script.log

  declare_env_variables
  check_out_infrastructure_code
  generate_service_account
  setup_ssl_files
  setup_environment_vars

  initialise_elk_terraform
  build_elk_infrastructure

  initialise_terraform
  build_infrastructure

  run_rolling_update
  notify_vof_team_via_slack

}

main "$@"
