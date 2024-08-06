FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy as buildstage

WORKDIR .
# RUN apt-get update && apt-get install -y python3 python3-dev libpng-dev libjpeg-dev p7zip-full p7zip-rar unrar-free libgl1 python3-pyqt5 python3-pip cmake
# RUN pip install PySide6 Pillow psutil requests python-slugify raven mozjpeg-lossless-optimization natsort[fast] distro

RUN curl -L https://archive.org/download/kindlegen_linux_2_6_i386_v2_9/kindlegen_linux_2.6_i386_v2_9.tar.gz > kindlegen.tar.gz
RUN tar -zxvf kindlegen.tar.gz kindlegen
RUN chmod +rwx 'kindlegen'
RUN cp -R 'kindlegen' '/usr/local/bin/'
RUN rm kindlegen.tar.gz

RUN latest_release_info=$(curl -s "https://api.github.com/repos/ciromattia/kcc/releases/latest")
RUN latest_tag=$(echo "$latest_release_info" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

RUN curl -L -o kcc.tar.gz https://github.com/ciromattia/kcc/archive/refs/tags/$latest_tag.tar.gz
RUN tar -xzf kcc.tar.gz && mv kcc-$(echo "$latest_tag" | sed 's/^.\(.*\)/\1/') kcc

# COPY root/ /root-layer/

## Single layer deployed image ##
FROM scratch

# Add files from buildstage
COPY --from=buildstage /kcc/ /