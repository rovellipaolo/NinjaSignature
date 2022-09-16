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
	@cpan -fi Test::More


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

.PHONY: checkstyle
checkstyle:
	perltidy -w -b -bext='/' *.pl lib/*/*.pm lib/*/*/*.pm t/*.t
