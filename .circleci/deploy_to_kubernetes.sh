#!/usr/bin/env bash

set -e

notify_vof_team_via_slack() {

  # send deployment notification to slack
  curl -X POST --data-urlencode \
  "payload={\"channel\": \"${DEPLOYMENT_CHANNEL}\", \"username\": \"DeployNotification\", \"text\": \"Git Commit Tag: <$COMMIT_LINK|${GIT_COMMIT_TAG}> has just been deployed to *${project}* :kubernetes: in *${environment}* :${EMOJI}:\", \"icon_emoji\": \":rocket:\"}" \
  "${SLACK_CHANNEL_HOOK}"
}

deploy() {

  # clone vof-deployment-scripts repo and setup variables
  git clone -b k8s-sandbox https://github.com/andela/vof-deployment-scripts.git ${HOME}/deployment_scripts
  cd ${HOME}/deployment_scripts
  bash ~/vof/.circleci/setup_env_vars.sh
  source .env

  # generate main.tf file and create terraform-init file
  . env_vars.sh
  mkdir secrets
  touch terraform-init

  if [ "$CIRCLE_BRANCH" == master ]; then

    # activate gcloud with service account key
    echo $GOOGLE_CREDENTIALS_PRODUCTION | base64 --decode > secrets/google-service-key.json
    gcloud auth activate-service-account --key-file secrets/google-service-key.json
    gcloud --quiet config set project ${PRODUCTION_PROJECT}
    gcloud --quiet config set compute/zone ${GOOGLE_COMPUTE_ZONE}

    # get ssl certificates
    gsutil cp gs://$SSL_BUCKET/andela_certificate.pem secrets/ssl_andela_certificate.crt
    gsutil cp gs://$SSL_BUCKET/andela_key.key secrets/ssl_andela_key.key

    # generate terraform-init file
    echo "bucket=\"$PRODUCTION_BUCKET\"" >> terraform-init
    echo "prefix=\"$PRODUCTION_PREFIX\"" >> terraform-init
    echo "credentials=\"$PRODUCTION_CREDENTIALS\"" >> terraform-init

    # create .env file and source it
    bash ~/vof/.circleci/setup_env_vars.sh
    source .env

    # initilise terraform
    terraform init -backend-config=terraform-init

    # pull current terraform state from GCS
    gsutil cp gs://$PRODUCTION_STATE_DIR/default.tfstate terraform.tfstate

    # terraform plan and apply the gke module
    terraform plan -target module.gke
    terraform apply -target module.gke -auto-approve

    # set credentials of the kurbernetes cluster
    gcloud container clusters get-credentials vof-tracker-$PRODUCTION_ENVIRONMENT

    # terraform plan and apply the k8s module
    terraform plan -target module.k8s
    terraform apply -target module.k8s -auto-approve

    # push new terraform state to GCS
    gsutil cp terraform.tfstate gs://$PRODUCTION_STATE_DIR/default.tfstate
  elif [ "$CIRCLE_BRANCH" == develop ]; then

    # activate gcloud with service account key
    echo $GOOGLE_CREDENTIALS_STAGING | base64 --decode > secrets/google-service-key.json
    gcloud auth activate-service-account --key-file secrets/google-service-key.json
    gcloud --quiet config set project ${STAGING_PROJECT}
    gcloud --quiet config set compute/zone ${GOOGLE_COMPUTE_ZONE}

    # get ssl certificates
    gsutil cp gs://$SSL_BUCKET/andela_certificate.pem secrets/ssl_andela_certificate.crt
    gsutil cp gs://$SSL_BUCKET/andela_key.key secrets/ssl_andela_key.key

    # generate terraform-init file
    echo "bucket=\"$STAGING_BUCKET\"" >> terraform-init
    echo "prefix=\"$STAGING_PREFIX\"" >> terraform-init
    echo "credentials=\"$STAGING_CREDENTIALS\"" >> terraform-init

    # create .env file and source it
    bash ~/vof/.circleci/setup_env_vars.sh
    source .env

    # initilise terraform
    terraform init -backend-config=terraform-init

    # pull current terraform state from GCS
    gsutil cp gs://$STAGING_STATE_DIR/default.tfstate terraform.tfstate

    # terraform plan and apply the gke module
    terraform plan -target module.gke
    terraform apply -target module.gke -auto-approve

    # set credentials of the kerbernetes cluster
    gcloud container clusters get-credentials vof-tracker-$STAGING_ENVIRONMENT

    # terraform plan and apply the k8s module
    terraform plan -target module.k8s
    terraform apply -target module.k8s -auto-approve

    # push new terraform state to GCS
    gsutil cp terraform.tfstate gs://$STAGING_STATE_DIR/default.tfstate
  else

    # activate gcloud with service account key
    echo $GOOGLE_CREDENTIALS_SANDBOX | base64 --decode > secrets/google-service-key.json
    gcloud auth activate-service-account --key-file secrets/google-service-key.json
    gcloud --quiet config set project ${SANDBOX_PROJECT}
    gcloud --quiet config set compute/zone ${GOOGLE_COMPUTE_ZONE}

    # get ssl certificates
    gsutil cp gs://$SSL_BUCKET/andela_certificate.pem secrets/ssl_andela_certificate.crt
    gsutil cp gs://$SSL_BUCKET/andela_key.key secrets/ssl_andela_key.key

    # generate terraform-init file
    echo "bucket=\"$SANDBOX_BUCKET\"" >> terraform-init
    echo "prefix=\"$SANDBOX_PREFIX\"" >> terraform-init
    echo "credentials=\"$SANDBOX_CREDENTIALS\"" >> terraform-init

    # create .env file and source it
    bash ~/vof/.circleci/setup_env_vars.sh
    source .env

    # initilise terraform
    terraform init -backend-config=terraform-init

    # pull current terraform state from GCS
    gsutil cp gs://$SANDBOX_STATE_DIR/default.tfstate terraform.tfstate

    # terraform plan and apply the gke module
    terraform plan -target module.gke
    terraform apply -target module.gke -auto-approve

    # set credentials of the kerbernetes cluster
    gcloud container clusters get-credentials vof-tracker-$SANDBOX_ENVIRONMENT

    # terraform plan and apply the k8s module
    terraform plan -target module.k8s
    terraform apply -target module.k8s -auto-approve

    # push new terraform state to GCS
    gsutil cp terraform.tfstate gs://$SANDBOX_STATE_DIR/default.tfstate


  fi
}

configure_database(){
  # authorize certain IPs to access staging db but not the production db
  if [ "$RAILS_ENV" != "production" ]; then
    CURRENTIPS="105.21.72.66,105.21.32.90,105.27.99.66,41.90.97.134,41.75.89.154,169.239.188.10,41.215.245.118"
  fi

  # ensure replica's authorized networks are also updated
  for sqlInstanceName in $(gcloud sql instances list --project vof-tracker-app | grep k8s-${RAILS_ENV}-vof-database-instance | awk -v ORS=" " '{if ($1 !~ /production-vof-database-instance-vew0wndaum8/) print $1}'); do
    gcloud sql instances patch $sqlInstanceName --quiet --authorized-networks=$CURRENTIPS,41.75.89.154,158.106.201.190,41.215.245.162,108.41.204.165,14.140.245.142,182.74.31.70,54.208.19.24,35.166.153.63,54.208.19.13,54.69.5.5,52.36.120.247,52.45.79.49,34.199.147.194,35.231.177.164
  done
}

main(){
  deploy
  configure_database
  notify_vof_team_via_slack
}

main "$@"
