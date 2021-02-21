#!/bin/bash

DOCKER_REGISTRY="us.gcr.io"
GCP_PROJECT_ID="apolloio"
DOCKER_IMAGE=${DOCKER_REGISTRY}/${GCP_PROJECT_ID}/apolloio
DOCKER_IMAGE_TAG=$(git rev-parse HEAD)

has_uncommited_changes() {
    output=$(git status --porcelain)
    if [ "${output}" != "" ]; then
        return 0
    fi
    return 1
}

docker_login() {
    gcloud auth configure-docker ${DOCKER_REGISTRY}
}

main() {
    if has_uncommited_changes; then
        echo "Git has uncommited changes. Exiting."
        exit 1
    fi

    docker_login
    docker build . -t ${DOCKER_IMAGE}:${DOCKER_IMAGE_TAG}
    docker push ${DOCKER_IMAGE}:${DOCKER_IMAGE_TAG}
}

main
