# Build context is the repo root (see docker-compose.yml), so both core/
# and frontend/ are visible for frontend's `core: {path: ../core}` dependency.
# Pinned to linux/amd64: the official Flutter Linux SDK archive below is
# x86_64-only, so this stage runs under emulation on arm64 hosts (e.g.
# Apple Silicon) — harmless at build time, and the output (the compiled
# web/ bundle copied into the nginx stage) is plain JS/HTML, not a binary,
# so it isn't architecture-specific either way.
FROM --platform=linux/amd64 debian:bookworm-slim AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Pinned to match this project's `sdk: ^3.12.2` constraint (frontend/pubspec.yaml) —
# Flutter 3.44.7 is the first stable release bundling that Dart SDK version.
ENV FLUTTER_VERSION=3.44.7
RUN curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    | tar -xJ -C /opt
ENV PATH="/opt/flutter/bin:${PATH}"
RUN git config --global --add safe.directory /opt/flutter \
    && flutter config --no-analytics \
    && flutter precache --web

WORKDIR /app
COPY core ./core
COPY frontend ./frontend

WORKDIR /app/frontend
RUN flutter pub get

# Baked in at build time: Flutter web reads this via String.fromEnvironment,
# and the compiled JS runs in the browser, not in this container, so it must
# point at wherever the backend is reachable from the browser.
ARG API_BASE_URL=http://localhost:8080
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

FROM nginx:1.27-alpine
COPY --from=build /app/frontend/build/web /usr/share/nginx/html

EXPOSE 80
