export APPNAME=app-name
export SERVICES=app

#
# develop
#

images:
	docker-compose build --pull --parallel --compress

show:
	docker-compose ps

start:
	docker-compose up --detach $(SERVICES)

stop:
	docker-compose stop $(SERVICES)

logs:
	docker-compose logs --follow $(SERVICES)

up:
	docker-compose up --detach shell

down:
	docker-compose stop --timeout=0 shell

shell:
	docker-compose exec shell /bin/bash

test:
	docker-compose run --rm shell ./test/suite

clean:
	docker-compose down --remove-orphans --volumes

#
# utilities
#

phony:
	@sed -ne 's/^\([[:alnum:]_-]\{1,\}\):.*/	\1 \\/p' Makefile | sed -e '$$s/ \\//'

.PHONY: \
	images \
	show \
	start \
	stop \
	logs \
	up \
	down \
	shell \
	test \
	clean \
	phony
