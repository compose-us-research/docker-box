#!/usr/bin/env bash

SCRIPT_PATH="$(cd "$(dirname "$0")"; pwd -P )"
APP_TO_RUN="$1"
shift

if [ -z ${DOCKER_BOX_APPS_PATH+x} ]; then
  DOCKER_BOX_APPS_PATH="${SCRIPT_PATH}/apps"
fi

APP_PATH="${DOCKER_BOX_APPS_PATH}/${APP_TO_RUN}"
DOCKER_COMPOSE_FILE="${APP_PATH}/docker-compose.yml"
VOLUME_DIR="$(pwd)"

if [ -f "${DOCKER_COMPOSE_FILE}" ]; then
  # Concatenate all remaining arguments and put them into quotes
  arguments=""
  for i in "$@"; do
    arguments="$arguments"'"'"$i"'" '
  done
  if [ -n "${arguments}" ]; then
    COMMAND="""docker-compose -f ${DOCKER_COMPOSE_FILE} run --rm --service-ports --use-aliases --volume \"${VOLUME_DIR}:/app\" app "$arguments""""
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
  DOCKER_BUILD_VERSION="${DOCKERFILE_HASH}"
  IMAGE_NAME="${APP_TO_RUN}:${DOCKER_BUILD_VERSION}"
  # If the docker image does not exist yet, create it
  if ! docker inspect "$IMAGE_NAME" > /dev/null; then
    echo "Building $IMAGE_NAME"
    docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" $APP_PATH
  fi

  # For running programs on XQuartz, DOCKER_X_OPTS need to be added to command
  # IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
  # xhost + $IP
  # DOCKER_X_OPTS="-v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=host.docker.internal:0"
        #  ${DOCKER_X_OPTS} \

  echo "Running $APP_TO_RUN"

  # Run the docker command with properly quoted arguments
  COMMAND="""docker run \
         --rm \
         --name \"$APP_TO_RUN\" \
         ${DOCKER_OPTIONS} \
         --volume \"${VOLUME_DIR}:/app\" \
         -it \
         \"$IMAGE_NAME\" \
         \"$APP_TO_RUN\" \"$arguments\"
  """
fi

bash -c "$COMMAND"
