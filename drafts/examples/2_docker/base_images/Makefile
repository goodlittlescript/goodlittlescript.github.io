TARGET=amazonlinux
VERSION=2
IMAGE=goodlittlescript-$(TARGET)

image:
	@docker build --compress --no-cache -f $(TARGET)/Dockerfile --build-arg VERSION=$(VERSION) --tag $(IMAGE):$(VERSION) --target base --pull . >&2
	@echo $(IMAGE):$(VERSION)
	@docker build --compress --no-cache -f $(TARGET)/Dockerfile --build-arg VERSION=$(VERSION) --tag $(IMAGE):$(VERSION)-shell --target shell . >&2
	@echo $(IMAGE):$(VERSION)-shell

images:
	@make image TARGET=alpine VERSION=3.10
	@make image TARGET=amazonlinux VERSION=2
	@make image TARGET=debian VERSION=buster-slim

run:
	docker run -it --rm $(IMAGE):$(VERSION)

shell:
	docker run -it --rm $(IMAGE):$(VERSION)-shell /bin/bash

.PHONY: \
	image \
	images \
	run \
	shell
