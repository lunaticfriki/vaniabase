# Build context is the repo root (see docker-compose.yml), so both core/
# and backend/ are visible for backend's `core: {path: ../core}` dependency.
FROM dart:stable AS build

WORKDIR /app
COPY core ./core
COPY backend ./backend

WORKDIR /app/backend
RUN dart pub get
RUN dart compile exe bin/server.dart -o /app/server

FROM debian:bookworm-slim
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app/server /app/server
COPY --from=build /app/backend/migrations /app/migrations
COPY --from=build /app/backend/openapi.yaml /app/openapi.yaml

EXPOSE 8080
CMD ["/app/server"]
