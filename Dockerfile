FROM debian:12-slim

RUN apt-get update && apt-get -y install \
    qemu-system-x86 iproute2 net-tools \
    && apt-get clean

WORKDIR /vm

COPY chr-7.16.img chr.img

EXPOSE 21 22 23 53 53/udp 80 443 179 8728 8729 8291

COPY qemu-wrapper.sh /usr/local/bin/qemu-wrapper.sh

RUN chmod +x /usr/local/bin/qemu-wrapper.sh

CMD ["/usr/local/bin/qemu-wrapper.sh"]