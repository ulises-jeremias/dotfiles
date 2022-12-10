# Arch Linux - Testing Environment

## Dependencies

- [Xephyr](https://wiki.archlinux.org/index.php/Xephyr)
- [Docker](https://www.docker.com/)

## Build Docker

Run the following command in the repository root directory:

```sh
docker build -f docker/arch-linux/Dockerfile -t arch-dotfiles .
```

## Run Docker

Create a windowed X-Server first

```sh
Xephyr :1225 -ac -br -screen 1024x768 -resizeable -reset -terminate
```

then, run the docker container

```sh
docker run -e DISPLAY=:1225 -v /tmp/.X11-unix:/tmp/.X11-unix arch-dotfiles <wm>
```

being `wm = i3 | openbox`
