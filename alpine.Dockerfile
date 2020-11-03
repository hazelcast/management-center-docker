FROM alpine:3.12.1

RUN echo "Installing new APK packages" \
    && apk add --no-cache openjdk11-jre
