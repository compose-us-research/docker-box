#!/usr/bin/env bash

APP_TO_RUN="$1"
shift
ARGUMENTS="$@"
SCRIPT_PATH="$(cd "$(dirname "$0")"; pwd -P )"

APP_PATH="${SCRIPT_PATH}/apps/${APP_TO_RUN}"
VOLUME_DIR="${SCRIPT_PATH}/sandbox"
DOCKERFILE="${APP_PATH}/Dockerfile"

DOCKERFILE_VERSION=$(md5 -q "$DOCKERFILE")
IMAGE_NAME="${APP_TO_RUN}:${DOCKERFILE_VERSION}"

# If the docker image does not exist yet, create it
if ! docker inspect "$IMAGE_NAME" > /dev/null; then
  echo "Building $IMAGE_NAME"
  docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" $APP_PATH
fi

echo "Running $APP_TO_RUN"
docker run \
       --rm \
       --name "$APP_TO_RUN" \
       --volume "${VOLUME_DIR}:/app" \
       "$IMAGE_NAME" \
       "$APP_TO_RUN" "$ARGUMENTS"
