# syntax=docker/dockerfile:1

FROM scratch

LABEL maintainer="hvmzx"

# copy local files
COPY root/ /root-layer/