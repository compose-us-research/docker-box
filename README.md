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
```

Usage for using it inside the current working directory:

```
box youtube-dl ...
```

Usage for not even giving the program the current working directory but using a static mount (`$INSTALL_DIRECTORY/sandbox/`):

```
mountbox youtube-dl ...
```
