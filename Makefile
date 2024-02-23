DOCKER_FILE :=  docker/Dockerfile
DOCKER_IMAGE := ninjasignature
DOCKER_TAG := latest
NINJASIGNATURE_HOME := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))


# Build:
.PHONY: build
build:
	@cpan -Ti Digest::SHA
	@cpan -Ti Getopt::Long
	@cpan -Ti Log::Log4perl
	@cpan -Ti Moose
	@cpan -Ti Moose::Role

.PHONY: build-dev
build-dev:
	make build
	@cpan -Ti Devel::Cover
	@cpan -Ti Perl::Tidy
	@cpan -Ti Test::Exception
	@cpan -Ti Test::MockObject
	@cpan -Ti Test::MockModule
	@cpan -Ti Test::Spec

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
	@cover -test -ignore_re '^t/.*'

.PHONY: test-docker
test-docker:
	@docker run --name ${DOCKER_IMAGE} --rm -w /opt/NinjaSignature -v ${NINJASIGNATURE_HOME}/t:/opt/NinjaSignature/t ${DOCKER_IMAGE}:${DOCKER_TAG} prove -r t

.PHONY: checkstyle
checkstyle:
	perltidy -w -b -bext='/' *.pl lib/*/*.pm lib/*/*/*.pm t/*.t
