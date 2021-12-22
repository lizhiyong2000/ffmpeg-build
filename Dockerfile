FROM ubuntu:20.04 AS build
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get -y --no-install-recommends install build-essential curl ca-certificates yasm \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    && update-ca-certificates

WORKDIR /app
COPY ./build-ffmpeg /app/build-ffmpeg

# ENV http_proxy "http://172.24.6.86:1087"
# ENV https_proxy "http://172.24.6.86:1087"
RUN /app/build-ffmpeg --build

FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive
# install va-driver
RUN apt-get update \
    # && apt-get -y install libva-drm2 \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Copy ffmpeg
COPY --from=build /app/workspace/bin/ffmpeg /usr/bin/ffmpeg
COPY --from=build /app/workspace/bin/ffprobe /usr/bin/ffprobe

# Check shared library
RUN ldd /usr/bin/ffmpeg
RUN ldd /usr/bin/ffprobe

CMD         ["--help"]
ENTRYPOINT  ["/usr/bin/ffmpeg"]
