# Quenta

## Configure Environment Variables

```
cp .env.example .env
```

## Start Database

```bash
docker compose up
```

(if `docker compose` doesn't work, try `docker-compose`)

## Initial Database Setup

Create the `quenta` database:

```
pnpm run graphile-migrate reset --erase
```

## Docker

### Build Docker Image Locally

```sh
docker build -t quenta/app .
```

### Run Docker Image Locally

```sh
docker run --rm --name quenta-app quenta/app
```
