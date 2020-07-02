# docker-box

Sandbox apps into a docker container.

With docker, you can install and run apps in a sandbox. The commands in this
repository should help you with that. No need for homebrew or other package
managers that install dependencies system wide. Make your system safer by not
installing apps globally. Uninstalling apps and their dependencies is done by
removing the docker images.

## Installation

Copy it into your home directory and make it runnable:

```
mkdir ~/.docker-box
cp -r . ~/.docker-box
chmod u+x ~/.docker-box/docker-box*.sh
```

Set up aliases in `.*rc` file:

```
alias mountbox="${HOME}/.docker-box/docker-box-static-mount.sh"
alias box="${HOME}/.docker-box/docker-box.sh"
alias boxed="${HOME}/.docker-box/docker-box-script.sh"
alias dr="${HOME}/.docker-box/docker-box-run.sh"
```

If you want to change the registry directory to something else than the `apps`
directory, you can change `DOCKER_BOX_APPS_PATH` to something else.

For example:

```
alias mountbox="DOCKER_BOX_APPS_PATH=${HOME}/.docker-box-apps ${HOME}/.docker-box/docker-box-static-mount.sh"
alias box="DOCKER_BOX_APPS_PATH=${HOME}/.docker-box-apps ${HOME}/.docker-box/docker-box.sh"
alias boxed="DOCKER_BOX_APPS_PATH=${HOME}/.docker-box-apps ${HOME}/.docker-box/docker-box-script.sh"
alias dr="${HOME}/.docker-box/docker-box-run.sh"
```

## Usage

There are four different use-cases currently to share data between your
sandboxed app (= the untrusted thing you want to run) and the host (= your
computer). If you have installed the four aliases as mentioned above, those
will match:

1. Having the current working directory in your container (= `box`)
2. Having the current working directory in your container and run it non-interactively (= `boxed`)
3. Have a static mount in your container (= `mountbox`)
4. Run the current directory like a docker container (for development) (= `dr`)

### 1. Mount the current working directory into `/app`

```
box youtube-dl ...
```

Would download the URL you passed as argument into the current directory
through `youtube-dl`.

### 1. Mount the current working directory into `/app`

```
boxed pdf-document-feeder my-scanned-document.pdf my-scanned-document-sorted.pdf
```

Would sort `my-scanned-document.pdf` when you used a PDF feeder without duplex
to scan it. It will not attach a terminal to it, so it could run, for example, 
in Automator scripts.

### 3. Mount a static sandbox directory into `/app`

```
mountbox youtube-dl ...
```

This will use the `sandbox` subdirectory below the `docker-box` scripts, thus
downloading into that directory when using the `youtube-dl` docker-box-app.

### 4. Directly run the current directory with a Dockerfile inside a container

```
dr cargo run --help
```

This is useful for development as it mounts the current directory into a
container and you can specify, install and setup all necessary development
tools and environment through your Dockerfile.

The image name will be the name of your current working directory.

## Building your own docker-boxed apps

Apps can be built with a `Dockerfile` that contains their installation
instructions. To make sure the volumes are correctly mounted, always set the
working directory of the docker container to `/app` by using the `WORKDIR /app`
directive inside the `Dockerfile`.

You can have a look at the [docker-box-apps
repository](https://github.com/compose-us-research/docker-box-apps) to see
examples of how apps are built.

### Using ports

You have two options for using ports with `docker-box`:

1. Use a regular `Dockerfile` and have people use the `DOCKER_OPTIONS`
   environmment variable to add them (for example: `DOCKER_OPTIONS="-p 8000:8000"`)
2. Use a `docker-compose.yml` and add the ports to the `app` service. It will
   run your commands with `--service-ports` to make them available.
