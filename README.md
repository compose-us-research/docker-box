# sandbox-docker

Sandbox apps into a docker container.

## Installation

Copy it into your home directory and make it runnable:
```
mkdir ~/.sandbox
cp -r . ~/.sandbox
chmod u+x ~/.sandbox/sandbox*.sh
```

Set up aliases in `.*rc` file:
```
alias mountbox="${HOME}/.sandbox/sandbox-static-mount.sh"
alias box="${HOME}/.sandbox/sandbox.sh"
```

Usage for using it inside the current working directory:

```
box youtube-dl ...
```

Usage for not even giving the program the current working directory but using a static mount (`$INSTALL_DIRECTORY/sandbox/`):

```
mountbox youtube-dl ...
```
