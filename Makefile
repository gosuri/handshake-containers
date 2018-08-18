HSD_IMAGE  = quay.io/ovrclk/hsd
HNSD_IMAGE = quay.io/ovrclk/hnsd

build: hsd.build hnsd.build

hsd.build: hsd.clean hsd.src hsd.image
hnsd.build: hnsd.clean hnsd.src hnsd.image

hsd.src:
	mkdir -p hsd/_build/hsd
	git clone https://github.com/handshake-org/hsd hsd/_build/hsd

hsd.image:
	cd hsd && docker build . -t $(HSD_IMAGE)

hsd.clean:
	rm -rf hsd/_build

hsd.push:
	docker push $(HSD_IMAGE)

hsd.runns: 
	docker run --rm -it -p 5301:53/udp $(HSD_IMAGE) --ns-host 0.0.0.0 --ns-port 53

hsd.runrs: 
	docker run --rm -it -p 5302:53/udp $(HSD_IMAGE) --rs-host 0.0.0.0 --rs-port 53

hnsd.src:
	mkdir -p hnsd/_build/hnsd
	git clone https://github.com/handshake-org/hnsd hnsd/_build/hnsd

hnsd.image:
	cd hnsd && docker build . -t $(HNSD_IMAGE)

hnsd.clean:
	rm -rf hnsd/_build

hnsd.push:
	docker push $(HNSD_IMAGE)

hnsd.run: 
	docker run --rm -it -p 5302:53/udp $(HNSD_IMAGE) --rs-host 0.0.0.0:53 --pool-size 4

testns:
	$(shell for n in "$(cat AUTHORITATIVE)"; do; dig @$(echo $n | awk '{print $1}') com NS ; done)

.PHONY: build hsd.build hsd.clean hsd.src hsd.image hsd.push hsd.runns hsd.runrs hnsd.build hnsd.clean hnsd.src hnsd.image hnsd.push hnsd.run
