IMAGE = quay.io/ovrclk/hnsd

build: clean src image

src:
	mkdir -p _build/hnsd
	git clone https://github.com/handshake-org/hnsd _build/hnsd

image:
	docker build . -t $(IMAGE)

clean:
	rm -rf _build

push:
	docker push $(IMAGE)

run: 
	docker run --rm -p 5353:53 $(IMAGE)
