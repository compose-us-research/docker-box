# docker-box

Sandbox apps into a docker container.

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
alias dr="${HOME}/.docker-box/docker-box-run.sh"
```

If you want to change the registry directory to something else than the `apps`
directory, you can change `DOCKER_BOX_APPS_PATH` to something else.

For example:

```
alias mountbox="DOCKER_BOX_APPS_PATH=${HOME}/.docker-box-apps ${HOME}/.docker-box/docker-box-static-mount.sh"
alias box="DOCKER_BOX_APPS_PATH=${HOME}/.docker-box-apps ${HOME}/.docker-box/docker-box.sh"
alias dr="${HOME}/.docker-box/docker-box-run.sh"
```

## Usage

There are three different use-cases currently to share data between your 
sandboxed app (= the untrusted thing you want to run) and the host (= your
computer). If you have installed the three aliases as mentioned above, those
will match:

1. Having the current working directory in your container (= `box`)
2. Have a static mount in your container (= `mountbox`)
3. Run the current directory like a docker container (for development) (= `dr`)

### 1. Mount the current working directory into `/app`

```
box youtube-dl ...
```

Would download the URL you passed as argument into the current directory 
through `youtube-dl`.

### 2. Mount a static sandbox directory into `/app`

```
mountbox youtube-dl ...
```

This will use the `sandbox` subdirectory below the `docker-box` scripts, thus
downloading into that directory when using the `youtube-dl` docker-box-app.

### 3. Directly run the current directory with a Dockerfile inside a container

```
dr cargo run --help
```

This is useful for development as it mounts the current directory into a 
container and you can specify, install and setup all necessary development 
tools and environment through your Dockerfile.

The image name will be the name of your current working directory.
