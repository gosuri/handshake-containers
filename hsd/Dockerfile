FROM node:8.11.4-jessie
RUN apt-get update && apt-get install -y -f build-essential automake libtool unbound dnsutils libunbound-dev
ENV PATH $PATH:/hsd/bin
ADD run.sh /run.sh
RUN chmod +x /run.sh
ADD _build/hsd /hsd
RUN cd hsd && npm install --production
ENTRYPOINT ["/run.sh"]
