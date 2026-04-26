# Stage 1: Build Flutter Web
FROM ubuntu:22.04 AS build-env

RUN apt-get update && \
    apt-get install -y curl git unzip xz-utils zip libglu1-mesa

RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b stable

ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter doctor

WORKDIR /app
COPY . .

# Ignorer les warnings et forcer le web
RUN flutter config --enable-web
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Optionnel: Copier une configuration Nginx personnalisée si nécessaire
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
