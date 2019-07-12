#!/usr/bin/env bash

setup_env_vars() {
  GIT_HASH=$(echo $CIRCLE_SHA1 | cut -c -7)
  GIT_COMMIT_TAG=$(git rev-parse --short HEAD)
  COMMIT_LINK="https://github.com/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/commit/${CIRCLE_SHA1}"
  EMOJIS=("celebrate"  "party_dinosaur"  "andela" "aw-yeah" "carlton-dance" "partyparrot" "dancing-penguin" "aww-yeah-remix" "monkey-dancing")
  RANDOM=$$$(date +%s)
  EMOJI=${EMOJIS[$RANDOM % ${#EMOJIS[@]} ]}
  if [ "$CIRCLE_BRANCH" == master ]; then
    echo "RAILS_ENV"=$(echo production) >> .env
    echo "PORT"=$(echo $PORT) >> .env
    echo "RAILS_SERVE_STATIC_FILES"=$(echo $RAILS_SERVE_STATIC_FILES) >> .env
    echo "region"=$(echo $REGION) >> .env
    echo "project"=$(echo $PRODUCTION_PROJECT) >> .env
    echo "zone"=$(echo $GOOGLE_COMPUTE_ZONE) >> .env
    echo "bucket"=$(echo $PRODUCTION_BUCKET) >> .env
    echo "prefix"=$(echo $PRODUCTION_PREFIX) >> .env
    echo "environment"=$(echo production) >> .env
    echo "machine_type"=$(echo $PRODUCTION_MACHINE_TYPE) >> .env
    echo "namespace"=$(echo production) >> .env
    echo "deployment_name"=$(echo vof-tracker) >> .env
    echo "deployment_port"=$(echo 80) >> .env
    echo "vof_tracker_image"=$(echo $DOCKER_IMAGE_URL_PRODUCTION:$GIT_HASH) >> .env
    echo "credentials"=$(echo $PRODUCTION_CREDENTIALS) >> .env
    echo "vof_domain_name"=$(echo $PRODUCTION_DOMAIN_NAME) >> .env
    echo "dbBackupNotificationToken"=$(echo $DB_BACKUP_NOTIFICATION_TOKEN) >> .env
    echo "BUGSNAG_API_KEY"=$(echo $PRODUCTION_BUGSNAG_KEY) >> .env
    echo "DEPLOYMENT_CHANNEL"=$(echo "$SLACK_CHANNEL") >> .env
    echo "SLACK_CHANNEL_HOOK"=$(echo "$SLACK_CHANNEL_HOOK") >> .env
    echo "COMMIT_LINK"=$(echo "$COMMIT_LINK") >> .env
    echo "GIT_COMMIT_TAG"=$(echo "$GIT_COMMIT_TAG") >> .env
    echo "PROJECT"=$(echo "$PRODUCTION_PROJECT") >> .env
    echo "EMOJI"=$(echo "$EMOJI") >> .env
    echo "google_storage_access_key_id"=$(echo $GOOGLE_STORAGE_ACCESS_KEY_ID) >> .env
    echo "google_storage_secret_access_key"=$(echo $GOOGLE_STORAGE_SECRET_ACCESS_KEY) >> .env
    echo "FRESHCHAT_TOKEN"=$(echo $FRESHCHAT_TOKEN) >> .env
    echo "GOOGLE_CREDENTIALS_PRODUCTION"=$(echo $GOOGLE_CREDENTIALS_PRODUCTION) >> .env

  elif [ "$CIRCLE_BRANCH" == develop ]; then
    echo "credentials"=$(echo $STAGING_CREDENTIALS) >> .env
    echo "RAILS_ENV"=$(echo staging) >> .env
    echo "PORT"=$(echo $PORT) >> .env
    echo "RAILS_SERVE_STATIC_FILES"=$(echo $RAILS_SERVE_STATIC_FILES) >> .env
    echo "region"=$(echo $REGION) >> .env
    echo "project"=$(echo $STAGING_PROJECT) >> .env
    echo "zone"=$(echo $GOOGLE_COMPUTE_ZONE) >> .env
    echo "bucket"=$(echo $STAGING_BUCKET) >> .env
    echo "prefix"=$(echo $STAGING_PREFIX) >> .env
    echo "environment"=$(echo $STAGING_ENVIRONMENT) >> .env
    echo "machine_type"=$(echo $STAGING_MACHINE_TYPE) >> .env
    echo "namespace"=$(echo staging) >> .env
    echo "deployment_name"=$(echo vof-tracker) >> .env
    echo "deployment_port"=$(echo 80) >> .env
    echo "vof_tracker_image"=$(echo $DOCKER_IMAGE_URL_STAGING:$GIT_HASH) >> .env
    echo "vof_domain_name"=$(echo $STAGING_DOMAIN_NAME) >> .env
    echo "BUGSNAG_API_KEY"=$(echo $BUGSNAG_KEY) >> .env
    echo "DEPLOYMENT_CHANNEL"=$(echo "$SLACK_CHANNEL") >> .env
    echo "SLACK_CHANNEL_HOOK"=$(echo $SLACK_CHANNEL_HOOK) >> .env
    echo "COMMIT_LINK"=$(echo "$COMMIT_LINK") >> .env
    echo "GIT_COMMIT_TAG"=$(echo "$GIT_COMMIT_TAG") >> .env
    echo "EMOJI"=$(echo "$EMOJI") >> .env
    echo "google_storage_access_key_id"=$(echo $GOOGLE_STORAGE_ACCESS_KEY_ID) >> .env
    echo "google_storage_secret_access_key"=$(echo $GOOGLE_STORAGE_SECRET_ACCESS_KEY) >> .env
    echo "FRESHCHAT_TOKEN"=$(echo $FRESHCHAT_TOKEN) >> .env
    echo "GOOGLE_CREDENTIALS_STAGING"=$(echo $GOOGLE_CREDENTIALS_STAGING) >> .env
  else
    echo "credentials"=$(echo $SANDBOX_CREDENTIALS) >> .env
    echo "RAILS_ENV"=$(echo sandbox) >> .env
    echo "PORT"=$(echo $PORT) >> .env
    echo "RAILS_SERVE_STATIC_FILES"=$(echo $RAILS_SERVE_STATIC_FILES) >> .env
    echo "region"=$(echo $REGION) >> .env
    echo "project"=$(echo $SANDBOX_PROJECT) >> .env
    echo "zone"=$(echo $SANDBOX_ZONE) >> .env
    echo "bucket"=$(echo $SANDBOX_BUCKET) >> .env
    echo "prefix"=$(echo $SANDBOX_PREFIX) >> .env
    echo "environment"=$(echo $SANDBOX_ENVIRONMENT) >> .env
    echo "machine_type"=$(echo $SANDBOX_MACHINE_TYPE) >> .env
    echo "namespace"=$(echo sandbox) >> .env
    echo "deployment_name"=$(echo vof-tracker) >> .env
    echo "deployment_port"=$(echo 80) >> .env
    echo "vof_tracker_image"=$(echo $DOCKER_IMAGE_URL_SANDBOX:$GIT_HASH) >> .env
    echo "vof_domain_name"=$(echo $SANDOX_DOMAIN_NAME) >> .env
    echo "BUGSNAG_API_KEY"=$(echo $SANDBOX_BUGSNAG_KEY) >> .env
    echo "DEPLOYMENT_CHANNEL"=$(echo $SLACK_CHANNEL) >> .env
    echo "SLACK_CHANNEL_HOOK"=$(echo $SLACK_CHANNEL_HOOK) >> .env
    echo "COMMIT_LINK"=$(echo "$COMMIT_LINK") >> .env
    echo "GIT_COMMIT_TAG"=$(echo "$GIT_COMMIT_TAG") >> .env
    echo "PROJECT"=$(echo "$SANDBOX_PROJECT") >> .env
    echo "EMOJI"=$(echo "$EMOJI") >> .env
    echo "google_storage_access_key_id"=$(echo $GOOGLE_STORAGE_ACCESS_KEY_ID) >> .env
    echo "google_storage_secret_access_key"=$(echo $GOOGLE_STORAGE_SECRET_ACCESS_KEY) >> .env
    echo "FRESHCHAT_TOKEN"=$(echo $FRESHCHAT_TOKEN) >> .env
    echo "GOOGLE_CREDENTIALS_SANDBOX"=$(echo $GOOGLE_CREDENTIALS_SANDBOX) >> .env
  fi
}

setup_env_vars
