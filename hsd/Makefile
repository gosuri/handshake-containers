IMAGE = quay.io/ovrclk/hsd

build: clean src image

src:
	mkdir -p _build/hsd
	git clone https://github.com/handshake-org/hsd _build/hsd

image:
	docker build . -t $(IMAGE)

clean:
	rm -rf _build

push:
	docker push $(IMAGE)

runns: 
	sudo docker run --rm -it -p 53:53/udp quay.io/ovrclk/hsd --ns-host 0.0.0.0 --ns-port 53

runrs: 
	sudo docker run --rm -it -p 53:53/udp quay.io/ovrclk/hsd --rs-host 0.0.0.0 --rs-port 53

push:
	docker push $(IMAGE)
