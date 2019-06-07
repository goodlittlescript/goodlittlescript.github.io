IMAGE_NAME=examples
TARGETS=ubuntu
TARGET?=ubuntu

#
# develop
#

images:
	@for target in $(TARGETS); \
	do docker build --target $$target -t $(IMAGE_NAME):$$target .; \
	done

test:
	docker run --rm -v $(PWD):/app $(IMAGE_NAME):$(TARGET) ./test/suite

shell:
	docker run -it --rm -v $(PWD):/app $(IMAGE_NAME):$(TARGET) /bin/bash

#
# utilities
#

phony:
	@sed -ne 's/^\([[:alnum:]_-]\{1,\}\):.*/	\1 \\/p' Makefile | sed -e '$$s/ \\//'

.PHONY: \
	images \
	test \
	shell \
	phony
