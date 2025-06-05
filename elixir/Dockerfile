# BUILD STAGE
# -----------------------------------------------------------------------------
FROM elixir:1.18.4-alpine AS build

# Install build dependencies
RUN apk add --no-cache git

# Set build-time environment variables
ENV MIX_ENV=prod

# Create app directory
WORKDIR /app

# Copy mix files
COPY mix.exs mix.lock ./

# Install Elixir dependencies
RUN mix deps.get --only prod
RUN mix deps.compile

# Copy source code
COPY . .

# Compile assets
RUN mix phx.digest

# Compile the project
RUN mix compile
RUN mix release

# RUNTIME STAGE
# -----------------------------------------------------------------------------
FROM alpine:3.18 AS runtime

# Install runtime dependencies
RUN apk add --no-cache openssl ncurses-libs libstdc++

# Create app user
RUN addgroup -g 1000 -S app && \
    adduser -u 1000 -S app -G app

# Create app directory
WORKDIR /app

# Copy the release from the build stage
COPY --from=build --chown=app:app /app/_build/prod/rel/quenta ./

# Copy the database CA certificate
COPY --chown=app:app quenta-db.pem /app/quenta-db.pem

# Copy the docker-app-start.sh script
COPY --chown=app:app docker-app-start.sh /app/docker-app-start.sh

# Switch to app user
USER app

# Expose the port
EXPOSE 4000

# Set environment variables
ENV MIX_ENV=prod
ENV PORT=4000
ENV PHX_HOST=localhost

# Start the application
CMD ["/app/docker-app-start.sh"]
