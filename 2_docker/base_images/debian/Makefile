DEBIAN_VERSION=stable-slim
IMAGE=goodlittlescript-debian

image:
	@docker build --compress --no-cache --build-arg DEBIAN_VERSION=$(DEBIAN_VERSION) --tag $(IMAGE):$(DEBIAN_VERSION) --target base --pull . >&2
	@echo $(IMAGE):$(DEBIAN_VERSION)
	@docker build --compress --no-cache --build-arg DEBIAN_VERSION=$(DEBIAN_VERSION) --tag $(IMAGE):$(DEBIAN_VERSION)-shell --target shell . >&2
	@echo $(IMAGE):$(DEBIAN_VERSION)-shell

images:
	@make image DEBIAN_VERSION=buster-slim

run:
	docker run -it --rm --user 900:00 $(IMAGE):$(DEBIAN_VERSION)

shell:
	docker run -it --rm --user 900:00 $(IMAGE):$(DEBIAN_VERSION)-shell /bin/bash

.PHONY: \
	image \
	images \
	run \
	shell
