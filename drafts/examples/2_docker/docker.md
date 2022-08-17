# Docker


## Overview

If you understand processes then you will understand docker.  Docker is a way to package up everything that makes a process.  Images are that package.  We start from an image and use `docker run` to make a container and launch a process within it.

```bash
docker run ubuntu whoami
# root

docker run ubuntu pwd
# /

docker run ubuntu ls -la
# /

docker run ubuntu env

docker run ubuntu ps -aux
```

Who am I, where am I, what do I have available.  To change the who/where/what you can use flags.

```bash
docker run ubuntu cat /etc/shadow
docker run --user nobody ubuntu whoami
# nobody

docker run --workdir /tmp ubuntu pwd
# /tmp

docker run -v $PWD:/app ubuntu ls -la
docker run -v $PWD:/app ubuntu ls -la /app

docker run --env KEY=value ubuntu env

export KEY="exported value"
docker run --env KEY ubuntu env
```

You can also detach to run in background and send signals.

```
container_id=$(docker run -d ubuntu sleep 300)
echo "$container_id"
docker ps
docker exec "$container_id" ps -aux
docker kill "$container_id"
```

Now let's try to interact with our process.

```bash
docker run ubuntu sed -e 's/in/out/' <<<"input"
# (nothing)
```

Doesn't work.  We use a specific flag, -i/--interactive, to keep stdin attached.

```bash
docker run -i ubuntu sed -e 's/in/out/' <<<"input"
# output
```

What about -t/--tty?

```bash
docker run -i -t ubuntu /bin/sh
whoami
read -s -p 'Password: ' password
printf "\nGot: %s\n" "$password"


docker run -i ubuntu /bin/sh
whoami
read -s -p 'Password: ' password
printf "\nGot: %s\n" "$password"
```

A tty is the keyboard and terminal.  You need it for shells, but can interfere if you aren't actually working with docker as a terminal.

```bash
printf "pipe not keyboard\n" | docker run ubuntu cat
printf "pipe not keyboard\n" | docker run -i ubuntu cat
printf "pipe not keyboard\n" | docker run -it ubuntu cat
```

So `-t` for a shell.  Typically no `-t` for other processes.  One last common flag: `--rm`.

```bash
docker ps
docker ps -a
```

Tons of garbage.  Cleanup with composition.

```bash
docker ps -aq
docker ps -aq | xargs printf "got: %s\n"
docker ps -aq | xargs docker rm
docker ps -a
```

Ongoing cleanup with --rm:

```bash
docker run ubuntu printf "no rm\n"
docker run --rm ubuntu printf "yes rm\n"
docker ps -a
```

Most of the run flags deal with some part of a process "world", some more esoteric than others.  Build is a way to move all the stuff up in the timeline, into the image.

```bash
cat > Dockerfile.basics <<DOC
FROM ubuntu
USER nobody
WORKDIR /tmp
COPY . /app
ENV KEY=value
DOC
docker build -f Dockerfile.basics -t basics .

docker run --rm basics whoami
docker run --rm basics pwd
docker run --rm basics ls -la /app
docker run --rm basics env
```

There are some subtleties though.  Look at the permissions on /app -- root:root.  This is different than if you just ran with the same intent:

```bash
docker run --rm basics ls -la /app
# -rw-r--r--  1 root root      5 Jun  7 20:49 .gitignore

docker run --rm -u nobody -v $PWD:/app ubuntu ls -la /app
# -rw-r--r--  1 nobody nogroup      5 Jun  7 20:49 .gitignore
```

It's a bad idea to run as root in the container as the underlying OS sees you as root even if you're in the container.  The specifics of those interactions ([capabilites](https://security.stackexchange.com/a/176350), etc) are beyond me but it's clear it's not a good idea.  So make a user and be intentional about what you do, including things like setting user id / group id.  Also do not do `--privileged` and things like docker-in-docker or docker-outside-of-docker unless you know the consequences better than I.

```bash
cat > Dockerfile.withuser <<DOC
FROM ubuntu
RUN mkdir -p /app && \
    groupadd -g 900 appuser && \
    useradd -r -u 900 -g appuser appuser -m -s /bin/bash && \
    chown -R appuser:appuser /app

USER appuser
COPY --chown=appuser:appuser . /app
DOC
docker build -f Dockerfile.withuser -t withuser .

docker run --rm withuser ls -la /app
# -rw-r--r--  1 appuser appuser   14 Jan 15  2019 .gitignore
```

Also be aware that `docker build` sends the entirety of `.` into the image where any part of it can and will be written into the image, for eternity.  This can and has been used recently for exploitation.

```bash
# sometimes contains credentials depending on how you cloned
docker run --rm withuser cat /app/.git/config

# look for any big-ish hex strings through all the repo's history
docker run --rm withuser grep -rE '[[:xdigit:]]{8,}' /app/.git
```

Use dockerignore to prevent this.

```bash
cat > .dockerignore <<DOC
.git
DOC
docker build -f Dockerfile.withuser -t withuser .
docker run --rm withuser cat /app/.git/config
# cat: /app/.git/config: No such file or directory
```

Images are like git histories in that they are built on reusable layers.  This is good because you can leverage this to do less work when building and distributing images.  This is bad because you have to pull all the layers to get the current one.  So this is no good either.

```bash
cat > Dockerfile.layersareforever <<DOC
FROM ubuntu
ENV SECRET=maybe_a_token_to_clone_a_repo
ENV SECRET=
DOC
docker build -f Dockerfile.layersareforever -t layersareforever .

docker run --rm layersareforever env

docker history layersareforever
prev_image_id=$(docker history layersareforever -q | head -n 2 | tail -n 1)
docker run --rm "$prev_image_id" env
```

It's likewise bad to add beefy layers because they will be with you forever.

```bash
cat > Dockerfile.layersareforever2 <<DOC
FROM ubuntu
COPY . /app
RUN rm -r /app
DOC
docker build -f Dockerfile.layersareforever2 -t layersareforever2 .

docker run --rm layersareforever2 ls /app

docker history layersareforever2
prev_image_id=$(docker history layersareforever2 -q | head -n 2 | tail -n 1)
docker run --rm "$prev_image_id" ls /app
```

Indeed much of the "game" with Docker is finding ways to not reuse work and to not build in secrets or big layers into the history of the image.  One trick is to use a build image and a deploy image.

```bash
cat > Dockerfile.buildanddeploy <<DOC
FROM ubuntu as build
RUN echo thisistheapp > /tmp/the_app
RUN echo junksideproduct > /tmp/junk_file

FROM ubuntu as deploy
COPY --from=build /tmp/the_app /app
DOC
docker build -f Dockerfile.buildanddeploy -t buildanddeploy .
docker run --rm buildanddeploy cat /app
```

Another trick is to build in steps.

```bash
cat > Dockerfile.targetbuild <<DOC
FROM ubuntu as base
RUN echo base > /tmp/the_base

FROM base as server
RUN echo server > /tmp/the_server

FROM base as shell
RUN echo shell > /tmp/the_shell
DOC

docker build -f Dockerfile.targetbuild -t targetbuild:server --target server .
docker run --rm targetbuild:server ls /tmp
# the_base
# the_server

docker build -f Dockerfile.targetbuild -t targetbuild:shell --target shell .
docker run --rm targetbuild:shell ls /tmp
# the_base
# the_shell
```

## docker-compose
