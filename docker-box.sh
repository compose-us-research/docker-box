#!/usr/bin/env bash

APP_TO_RUN="$1"
SCRIPT_PATH="$(cd "$(dirname "$0")"; pwd -P )"

if [ -z ${DOCKER_BOX_APPS_PATH+x} ]; then
  DOCKER_BOX_APPS_PATH="${SCRIPT_PATH}/apps"
fi

APP_PATH="${DOCKER_BOX_APPS_PATH}/${APP_TO_RUN}"
DOCKERFILE="${APP_PATH}/Dockerfile"
DOCKERFILE_VERSION=$(md5 -q "$DOCKERFILE")
IMAGE_NAME="${APP_TO_RUN}:${DOCKERFILE_VERSION}"
VOLUME_DIR="$(pwd)"

# If the docker image does not exist yet, create it
if ! docker inspect "$IMAGE_NAME" > /dev/null; then
  echo "Building $IMAGE_NAME"
  docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" $APP_PATH
fi

# Concatenate all remaining arguments and put them into quotes
shift
arguments=""
for i in "$@"; do
  arguments="$arguments"'"'"$i"'" '
done

echo "Running $APP_TO_RUN"

# Run the docker command with properly quoted arguments
echo docker run \
       --rm \
       --name "$APP_TO_RUN" \
       --volume "${VOLUME_DIR}:/app" \
       "$IMAGE_NAME" \
       "$APP_TO_RUN" "$arguments" | sh
