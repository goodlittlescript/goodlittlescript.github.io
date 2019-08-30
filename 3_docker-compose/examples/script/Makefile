export APPNAME=app-name

#
# develop
#

clean:
	docker-compose down --remove-orphans --rmi all

images:
	docker-compose build

run:
	docker-compose -f docker-compose.yml run --rm app

test:
	docker-compose run --rm shell ./test/suite

shell:
	docker-compose run --rm shell /bin/bash

#
# deploy
#

artifacts:
	make images test >&2

#
# utilities
#

phony:
	@sed -ne 's/^\([[:alnum:]_-]\{1,\}\):.*/	\1 \\/p' Makefile | sed -e '$$s/ \\//'

.PHONY: \
	clean \
	images \
	run \
	test \
	shell \
	artifacts \
	phony
