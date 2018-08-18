FROM ubuntu:xenial
RUN apt-get update && apt-get install -y build-essential automake libtool unbound dnsutils libunbound-dev libuv-dev
ADD _build/hnsd /hnsd
RUN cd hnsd && \
    ./autogen.sh && \
    ./configure && \
    make
ENV PATH $PATH:/hnsd
ADD run.sh /run.sh
RUN chmod +x /run.sh
ENTRYPOINT ["/run.sh"]
