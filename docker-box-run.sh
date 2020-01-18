#!/usr/bin/env bash

APP_TO_RUN="$(basename $(pwd))"
SCRIPT_PATH="$(cd "$(dirname "$0")"; pwd -P )"

APP_PATH="."
DOCKERFILE="${APP_PATH}/Dockerfile"
DOCKERFILE_VERSION=$(md5 -q "$DOCKERFILE")
IMAGE_NAME="${APP_TO_RUN}:${DOCKERFILE_VERSION}"
VOLUME_DIR="$(pwd)"

# If the docker image does not exist yet, create it
if ! docker inspect "$IMAGE_NAME" > /dev/null; then
  echo "Building $IMAGE_NAME"
  docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" $APP_PATH
fi

# Concatenate all arguments and put them into quotes
arguments=""
for i in "$@"; do
  arguments="$arguments"'"'"$i"'" '
done

echo "Running $APP_TO_RUN"

PORT_SETTING=""
if [ ! -z "$PORT" ]; then
  PORT_SETTING="-p ${PORT}:${PORT}"
fi

# Run the docker command with properly quoted arguments
COMMAND="""docker run \
       --rm \
       --name "$APP_TO_RUN" \
       ${PORT_SETTING} \
       --volume "${VOLUME_DIR}:/app" \
       -it \
       "$IMAGE_NAME" \
       "$arguments"
"""

bash -c "$COMMAND"
