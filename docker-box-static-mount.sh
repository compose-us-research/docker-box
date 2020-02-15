#!/usr/bin/env bash

SCRIPT_PATH="$(cd "$(dirname "$0")"; pwd -P )"
APP_TO_RUN="$1"
shift

if [ -z ${DOCKER_BOX_APPS_PATH+x} ]; then
  DOCKER_BOX_APPS_PATH="${SCRIPT_PATH}/apps"
fi

APP_PATH="${DOCKER_BOX_APPS_PATH}/${APP_TO_RUN}"
DOCKER_COMPOSE_FILE="${APP_PATH}/docker-compose.yml"
VOLUME_DIR="${SCRIPT_PATH}/sandbox"

if [ -f "${DOCKER_COMPOSE_FILE}" ]; then
  # Concatenate all remaining arguments and put them into quotes
  arguments=""
  for i in "$@"; do
    arguments="$arguments"'"'"$i"'" '
  done
  if [ -n "${arguments}" ]; then
    COMMAND="""docker-compose -f ${DOCKER_COMPOSE_FILE} run --rm --service-ports --volume "${VOLUME_DIR}:/app" app "$arguments""""
  else
    COMMAND="""docker-compose -f ${DOCKER_COMPOSE_FILE} up"""
  fi
else
  # Concatenate all remaining arguments and put them into quotes
  arguments=""
  for i in "$@"; do
    arguments="$arguments"'"'"$i"'" '
  done

  DOCKERFILE="${APP_PATH}/Dockerfile"
  DOCKERFILE_HASH=$(md5 -q "${DOCKERFILE}")
  DOCKER_BUILD_VERSION=$(echo "${DOCKERFILE_HASH}${DOCKER_COMPOSE_HASH}" | md5)
  IMAGE_NAME="${APP_TO_RUN}:${DOCKER_BUILD_VERSION}"
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
         "$APP_TO_RUN" "$arguments"
  """
fi

bash -c "$COMMAND"
