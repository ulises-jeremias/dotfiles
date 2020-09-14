# How to run dockers

### Dependecies:
- Xephyr
- Docker

---

### Build Dockerfile:
Run the following command in the repository root directory:
```bash
$ docker build -f docker/arch-linux/Dockerfile -t arch-dotfiles .
```

---

### Runing docker
First, create a windowed X-Server

```bash
$ Xephyr :1225 -ac -br -screen 1024x768 -resizeable -reset -terminate
```

then run the docker

```bash
$ docker run -e DISPLAY=:1225 -v /tmp/.X11-unix:/tmp/.X11-unix arch-dotfiles i3
```