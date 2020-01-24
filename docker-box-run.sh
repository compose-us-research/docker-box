#!/usr/bin/env bash

APP_TO_RUN="$(basename $(pwd))"
SCRIPT_PATH="$(cd "$(dirname "$0")"; pwd -P )"

APP_PATH="."
DOCKER_COMPOSE_FILE="${APP_PATH}/docker-compose.yml"

# Concatenate all arguments and put them into quotes
arguments=""
for i in "$@"; do
  arguments="$arguments"'"'"$i"'" '
done

if [ -f "${DOCKER_COMPOSE_FILE}" ]; then
  if [ -n "${arguments}" ]; then
    docker-compose run app "$arguments"
  else
    docker-compose up
  fi
else
  DOCKERFILE="${APP_PATH}/Dockerfile"
  DOCKERFILE_VERSION=$(md5 -q "$DOCKERFILE")
  IMAGE_NAME="${APP_TO_RUN}:${DOCKERFILE_VERSION}"
  VOLUME_DIR="$(pwd)"
  # If the docker image does not exist yet, create it
  if ! docker inspect "$IMAGE_NAME" > /dev/null; then
    echo "Building $IMAGE_NAME"
    docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" $APP_PATH
  fi

  echo "Running $APP_TO_RUN"

  # Run the docker command with properly quoted arguments
  COMMAND="""docker run \
         --rm \
         --name "$APP_TO_RUN" \
         ${DOCKER_OPTIONS} \
         --volume "${VOLUME_DIR}:/app" \
         -it \
         "$IMAGE_NAME" \
         "$arguments"
  """

  bash -c "$COMMAND"
fi
