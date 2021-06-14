FROM amd64/debian:bullseye
LABEL com.iximiuz-project="docker-os"
RUN apt-get -y update
RUN apt-get -y --no-install-recommends install extlinux syslinux-common fdisk
RUN rm -rf /var/lib/apt/lists/*
