FROM --platform=linux/amd64 debian:bookworm-slim AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git xz-utils \
    && rm -rf /var/lib/apt/lists/*

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

RUN flutter build web --release

FROM nginx:1.27-alpine
COPY --from=build /app/frontend/build/web /usr/share/nginx/html

EXPOSE 80
