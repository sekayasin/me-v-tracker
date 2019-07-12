#!/usr/bin/env bash

set -e

build_docker_image() {
  GIT_HASH=$(echo $CIRCLE_SHA1 | cut -c -7)
  mkdir secrets
  if [ "$CIRCLE_BRANCH" == master ]; then

    # activate gcloud with service account key
    echo $GOOGLE_CREDENTIALS_PRODUCTION | base64 --decode > ${HOME}/gcloud-service-key.json
    gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json
    gcloud --quiet config set project ${PRODUCTION_PROJECT}
    gcloud --quiet config set compute/zone ${GOOGLE_COMPUTE_ZONE}

    # update the current_version and previous_version files
    gsutil cp gs://${VOF_TRACKER_IMAGE_VERSION_PATH_PRODUCTION}/current_version .
    cat current_version > previous_version
    echo $GIT_HASH > current_version

    # generate an application.yml config file
    bash ./.circleci/create_app_config.sh $ENVIRONMENT

    # copy the Dockerfile, start script, backup script and post_backup_to_slack script from vof-deployment-scripts
    cp ${HOME}/deployment_scripts/docker/production/* .
    cp ${HOME}/deployment_scripts/packer/vof/{backup.sh,post_backup_to_slack.sh} .

    # get ssl certificates
    gsutil cp gs://$SSL_BUCKET/andela_certificate.pem secrets/ssl_andela_certificate.crt
    gsutil cp gs://$SSL_BUCKET/andela_key.key secrets/ssl_andela_key.key

    # generate .env file
    bash ~/vof/.circleci/setup_env_vars.sh

    # docker login, docker build, docker push
    docker login -u _json_key -p "$(echo $GOOGLE_CREDENTIALS_PRODUCTION | base64 --decode)" https://eu.gcr.io
    docker build -f Dockerfile -t ${DOCKER_IMAGE_URL_PRODUCTION}:$GIT_HASH .
    gcloud auth configure-docker
    docker push ${DOCKER_IMAGE_URL_PRODUCTION}:$GIT_HASH

    # push updated version files
    gsutil cp current_version gs://${VOF_TRACKER_IMAGE_VERSION_PATH_PRODUCTION}
    gsutil cp previous_version gs://${VOF_TRACKER_IMAGE_VERSION_PATH_PRODUCTION}
  elif [ "$CIRCLE_BRANCH" == develop ]; then

    # activate gcloud with service account key
    echo $GOOGLE_CREDENTIALS_STAGING | base64 --decode > ${HOME}/gcloud-service-key.json
    gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json
    gcloud --quiet config set project ${STAGING_PROJECT}
    gcloud --quiet config set compute/zone ${GOOGLE_COMPUTE_ZONE}

    # update the current_version and previous_version files
    gsutil cp gs://${VOF_TRACKER_IMAGE_VERSION_PATH_STAGING}/current_version .
    cat current_version > previous_version
    echo $GIT_HASH > current_version

    # generate an application.yml config file
    bash ./.circleci/create_app_config.sh $ENVIRONMENT

    # copy the Dockerfile and start_script from vof-deployment-scripts
    cp ${HOME}/deployment_scripts/docker/production/* .

    # copy backup.sh and post_backup_to_slack.sh to container
    cp ${HOME}/deployment_scripts/packer/vof/{backup.sh,post_backup_to_slack.sh} .

    # get ssl certificates
    gsutil cp gs://$SSL_BUCKET/andela_certificate.pem secrets/ssl_andela_certificate.crt
    gsutil cp gs://$SSL_BUCKET/andela_key.key secrets/ssl_andela_key.key

    # generate .env file
    bash ~/vof/.circleci/setup_env_vars.sh

    # docker login, docker build, docker push
    docker login -u _json_key -p "$(echo $GOOGLE_CREDENTIALS_STAGING | base64 --decode)" https://eu.gcr.io
    docker build -f Dockerfile -t ${DOCKER_IMAGE_URL_STAGING}:$GIT_HASH .
    gcloud auth configure-docker
    docker push ${DOCKER_IMAGE_URL_STAGING}:$GIT_HASH

    # push updated version files
    gsutil cp current_version gs://${VOF_TRACKER_IMAGE_VERSION_PATH_STAGING}
    gsutil cp previous_version gs://${VOF_TRACKER_IMAGE_VERSION_PATH_STAGING}
  else

    # activate gcloud with service account key
    echo $GOOGLE_CREDENTIALS_SANDBOX | base64 --decode > ${HOME}/gcloud-service-key.json
    gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json
    gcloud --quiet config set project ${GOOGLE_PROJECT_ID_SANDBOX}
    gcloud --quiet config set compute/zone ${GOOGLE_COMPUTE_ZONE}

    # update the current_version and previous_version files
    gsutil cp gs://${VOF_TRACKER_IMAGE_VERSION_PATH_SANDBOX}/current_version .
    cat current_version > previous_version
    echo ${GIT_HASH} > current_version

    # copy the Dockerfile and start_script from vof-deployment-scripts
    cp ${HOME}/deployment_scripts/docker/production/* .

    # copy backup.sh and post_backup_to_slack.sh to container
    cp ${HOME}/deployment_scripts/packer/vof/{backup.sh,post_backup_to_slack.sh} .

    # generate an application.yml config file
    bash ./.circleci/create_app_config.sh $ENVIRONMENT

    # generate .env file
    bash ~/vof/.circleci/setup_env_vars.sh

    # docker login, docker build, docker push
    docker login -u _json_key -p "$(echo $GOOGLE_CREDENTIALS_SANDBOX | base64 --decode )" https://gcr.io
    docker build -f Dockerfile -t ${DOCKER_IMAGE_URL_SANDBOX}:$GIT_HASH .
    gcloud auth configure-docker
    docker push ${DOCKER_IMAGE_URL_SANDBOX}:$GIT_HASH

    # push updated version files
    gsutil cp current_version gs://${VOF_TRACKER_IMAGE_VERSION_PATH_SANDBOX}
    gsutil cp previous_version gs://${VOF_TRACKER_IMAGE_VERSION_PATH_SANDBOX}
  fi
}

build_docker_image
