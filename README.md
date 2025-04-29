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
