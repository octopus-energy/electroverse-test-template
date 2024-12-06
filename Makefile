# Put any command that doesn't create a file here (almost all of the commands)
OS := $(shell uname)

.PHONY: \
	black \
	black_check \
	build \
	chown \
	clear_pyc \
	help \
	isort \
	isort_check \
	lint \
	manage \
	migrate \
	migrations \
	mypy \
	prep \
	psql \
	shell \
	test \
	up \
	usage \

usage:
	@echo "Available commands:"
	@echo "black....................Format Python code"
	@echo "black_check..............Checks Python code formatting without making changes"
	@echo "build....................Builds the django docker image"
	@echo "chown....................Change ownership of files to own user"
	@echo "clear_pyc................Remove all pyc files"
	@echo "help.....................Display available commands"
	@echo "isort....................Sort Python imports"
	@echo "isort_check..............Checks Python import are sorted correctly without making changes"
	@echo "lint.....................Run lint checking against the project"
	@echo "manage...................Run a Django management command"
	@echo "migrate..................Run Django migrations"
	@echo "migrations...............Create Django migrations"
	@echo "mypy.....................Run mypy type hint inspection against project"
	@echo "prep.....................Run all linting checks"
	@echo "psql.....................Log into postgis server"
	@echo "shell....................Run Django command line"
	@echo "test.....................Run Django tests"
	@echo "up.......................Start the Django server"
	@echo "usage....................Display available commands"

build:
	COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose build django

black:
	@docker-compose run --rm django black src ${ARGS}
ifneq ($(OS),Darwin)
	$(MAKE) chown
endif

black_check:
	$(MAKE) black ARGS="--check"

chown:
	@docker-compose run --rm django chown -R "`id -u`:`id -u`" "/usr/src/app/${ARGS}"

clear_pyc:
	@docker-compose run --rm django find . -name '*.pyc' -delete

help:
	$(MAKE) usage

isort:
	@docker-compose run --rm django isort src ${ARGS}
ifneq ($(OS),Darwin)
	$(MAKE) chown
endif

isort_check:
	$(MAKE) isort ARGS="--check"

lint:
	@docker-compose run --rm django flake8 src ${ARGS}

manage:
	@docker-compose run --rm ${OPTIONS} django python ${PYTHON_ARGS} manage.py ${ARGS}

migrate:
	$(MAKE) manage ARGS="migrate ${ARGS}"

migrations:
	$(MAKE) manage ARGS="makemigrations ${ARGS}"
ifneq ($(OS),Darwin)
	$(MAKE) chown
endif

mypy:
	@docker-compose run --rm django mypy django ${ARGS}

PG_DB_HOST=db
PG_DB_PORT=5432
PG_DB_NAME=postgres
PG_DB_USER=postgres
PG_DB_PASSWORD=postgres

db:
	@docker-compose run --rm -e PGPASSWORD=$(PG_DB_PASSWORD) db psql -h $(PG_DB_HOST) -p $(PG_DB_PORT) -U $(PG_DB_USER) -d $(PG_DB_NAME) $(ARGS)

prep:
	@docker-compose run --no-deps --rm django /bin/sh -c "isort src && black src && mypy --cache-dir=/dev/null src && flake8 src"

shell:
	$(MAKE) manage ARGS="shell ${ARGS}"

test:
	@docker-compose run --rm ${OPTIONS} django pytest ${ARGS}

up:
	@docker-compose up ${ARGS} django

down:
	@docker-compose down -v
