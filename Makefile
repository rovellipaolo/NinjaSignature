DOCKER_FILE :=  docker/Dockerfile
DOCKER_IMAGE := ninjasignature
DOCKER_TAG := latest
NINJASIGNATURE_HOME := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))


# Build:
.PHONY: build
build:
	@cpan -fi Digest::SHA
	@cpan -fi Getopt::Long
	@cpan -fi Log::Log4perl
	@cpan -fi Moose
	@cpan -fi Moose::Role

.PHONY: build-dev
build-dev:
	make build
	@cpan -fi Devel::Cover
	@cpan -fi Perl::Tidy
	@cpan -fi Test::Exception
	@cpan -fi Test::MockObject
	@cpan -fi Test::MockModule
	@cpan -fi Test::Spec

.PHONY: build-docker
build-docker:
	@docker build -f ${DOCKER_FILE} -t ${DOCKER_IMAGE}:${DOCKER_TAG} .


# Install:
.PHONY: install
install:
	sudo ln -s ${NINJASIGNATURE_HOME}/ninjasignature.pl /usr/local/bin/ninjasignature

.PHONY: uninstall
uninstall:
	sudo unlink /usr/local/bin/ninjasignature


# Test:
.PHONY: test
test:
	@prove -r t

.PHONY: test-coverage
test-coverage:
	@cover -test

.PHONY: test-docker
test-docker:
	@docker run --name ${DOCKER_IMAGE} --rm -w /opt/NinjaSignature -v ${NINJASIGNATURE_HOME}/t:/opt/NinjaSignature/t ${DOCKER_IMAGE}:${DOCKER_TAG} prove -r t

.PHONY: checkstyle
checkstyle:
	perltidy -w -b -bext='/' *.pl lib/*/*.pm lib/*/*/*.pm t/*.t
