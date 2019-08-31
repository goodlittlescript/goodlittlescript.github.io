VERSION=latest
IMAGE=goodlittlescript-alpine

image:
	@docker build --compress --no-cache --build-arg VERSION=$(VERSION) --tag $(IMAGE):$(VERSION) --target base --pull . >&2
	@echo $(IMAGE):$(VERSION)
	@docker build --compress --no-cache --build-arg VERSION=$(VERSION) --tag $(IMAGE):$(VERSION)-shell --target shell . >&2
	@echo $(IMAGE):$(VERSION)-shell

images:
	@make image VERSION=3.10

run:
	docker run -it --rm --user 900:900 $(IMAGE):$(VERSION)

shell:
	docker run -it --rm --user 900:900 $(IMAGE):$(VERSION)-shell /bin/bash

.PHONY: \
	image \
	images \
	run \
	shell
