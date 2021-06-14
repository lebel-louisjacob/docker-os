FROM alpine:latest
LABEL com.iximiuz-project="docker-os"
RUN apk add --no-cache linux-virt openrc docker
RUN rc-update add docker boot

COPY docker/remount.sh /etc/local.d/remount.start
RUN chmod +x /etc/local.d/remount.start
RUN rc-update add local boot

RUN echo "root:root" | chpasswd
