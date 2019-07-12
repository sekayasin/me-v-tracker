#!/bin/bash

export EMOJIS=(":celebrate:"  ":party_dinosaur:"  ":andela:" ":aw-yeah:" ":carlton-dance:" ":partyparrot:" ":dancing-penguin:" ":aww-yeah-remix:" ":monkey-dancing:")
export RANDOM=$$$(date +%s)
export EMOJI=${EMOJIS[$RANDOM % ${#EMOJIS[@]} ]}
export BUILD_BRANCH_COMMITS="https://github.com/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/commits/${CIRCLE_BRANCH}"
export COMMIT_LINK="https://github.com/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/commit/${CIRCLE_SHA1}"
export DEPLOYMENT_CHANNEL=${SLACK_CHANNEL}
export GIT_COMMIT_TAG=$(git rev-parse --short HEAD)
export WORKFLOW_LINK="https://circleci.com/workflow-run/${CIRCLE_WORKFLOW_ID}"