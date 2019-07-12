#!/bin/bash

set -ex
set -o pipefail

echo "building the packer image"
declare_env_variables() {
  DEPLOYMENT_ENVIRONMENT="staging"
  PACKER_IMG_TAG=""
  if [ "$CIRCLE_BRANCH" == 'master' ]; then
    DEPLOYMENT_ENVIRONMENT="production"
    RESERVED_IP=${PRODUCTION_RESERVED_IP}
  fi

  if [ "$CIRCLE_BRANCH" == 'design-v2' ]; then
    DEPLOYMENT_ENVIRONMENT="design-v2"
    RESERVED_IP=${DESIGN_V2_RESERVED_IP}
  fi

  if [[ "$CIRCLE_BRANCH" =~ 'sandbox' ]]; then
    DEPLOYMENT_ENVIRONMENT="sandbox"
    RESERVED_IP=${SANDBOX_RESERVED_IP}
  fi
}

generate_service_account() {
    touch /home/circleci/vof-repo/shared/account.json
    echo ${SERVICE_ACCOUNT} > /home/circleci/vof-repo/shared/account.json
}

build_packer_image() {
    echo "Rebuilding the packer image"

    pushd /home/circleci/vof-repo/packer
        touch packer_output.log
        RAILS_ENV="$DEPLOYMENT_ENVIRONMENT" VOF_PATH="/home/circleci/vof" PROJECT_ID="$GCLOUD_VOF_PROJECT" packer build packer.json 2>&1 | tee packer_output.log
        PACKER_IMG_TAG="$(grep 'A disk image was created:' packer_output.log | cut -d' ' -f8)"
    popd
    mkdir -p workspace
    echo $PACKER_IMG_TAG > ~/vof/workspace/output
    cat ~/vof/workspace/output

}

check_out_infrastructure_code() {
    echo "Checkout the infrastructure code"

    mkdir -p /home/circleci/vof-repo
    git clone -b master ${VOF_INFRASTRUCTURE_REPO} /home/circleci/vof-repo
}

save_image_tag() {
    gcloud auth activate-service-account --key-file=/home/circleci/vof-repo/shared/account.json
    cd workspace
    gsutil cp gs://${GCLOUD_VOF_BUCKET}/state/${DEPLOYMENT_ENVIRONMENT}/images/image_tags.txt .
    echo $PACKER_IMG_TAG >> ~/vof/workspace/image_tags.txt
    gsutil cp ~/vof/workspace/image_tags.txt gs://${GCLOUD_VOF_BUCKET}/state/${DEPLOYMENT_ENVIRONMENT}/images/image_tags.txt
}

main (){
    declare_env_variables
    check_out_infrastructure_code
    generate_service_account
    build_packer_image
    save_image_tag
}
main "@$"