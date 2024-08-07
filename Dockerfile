FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy as buildstage

WORKDIR .

RUN curl -L https://archive.org/download/kindlegen_linux_2_6_i386_v2_9/kindlegen_linux_2.6_i386_v2_9.tar.gz > kindlegen.tar.gz
RUN tar -zxvf kindlegen.tar.gz kindlegen
RUN chmod +rwx 'kindlegen'
RUN rm kindlegen.tar.gz

RUN latest_release_info=$(curl -s "https://api.github.com/repos/ciromattia/kcc/releases/latest") && \
    latest_tag=$(echo "$latest_release_info" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/') && \
    curl -L https://github.com/ciromattia/kcc/archive/refs/tags/$latest_tag.tar.gz > kcc.tar.gz && \
    tar -xzf kcc.tar.gz && \
    mv kcc-$(echo "$latest_tag" | sed 's/^.\(.*\)/\1/') kcc && \
    touch kcc/KCC_VERSION && \
    echo $latest_tag > kcc/KCC_VERSION && \
    mkdir -p /root-layer/usr/local/bin && \
    mv kindlegen /root-layer/usr/local/bin/ && \
    mv kcc /root-layer/usr/local/bin/

COPY root/ /root-layer/

## Single layer deployed image ##
FROM scratch

LABEL maintainer="hvmzx"

# Add files from buildstage
COPY --from=buildstage /root-layer/ /