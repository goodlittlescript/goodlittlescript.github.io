# Workflow

### Setup

Set secrets into the .env file -- docker-compose automatically uses these as override values.  Make images.

```bash
cp .env.example .env
make images
```

### Development Workflow

In this workflow the project directory is mounted into the container, so generally speaking you do not need to `make images` as your code changes.  You can `make shell` to get as many shells into your container as you like -- think of it as spinning up a disposable VM with all your dependencies available.

```bash
make up
make shell
make down
```

### Run Workflow

This workflow runs your app locally, so it uses your images as-is (ie you need to `make images` to include the current code).  Use this to preview your app.  Generally speaking you need this less frequently than the development workflow, but can be helpful for reproducing runtime issues.

```bash
make start
make logs
make stop
```

### Cleanup

Removes containers belonging to this project.

```bash
make clean
```
