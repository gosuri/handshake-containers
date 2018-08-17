FROM ubuntu:xenial
RUN apt-get update && apt-get install -y build-essential automake libtool unbound dnsutils libunbound-dev libuv-dev
ADD run.sh /run.sh
RUN chmod +x /run.sh
ADD _build/hnsd /build
RUN cd build && \
    ./autogen.sh && \
    ./configure && \
    make && \
    cp ./hnsd /usr/bin
#ENTRYPOINT ["/run.sh"]
