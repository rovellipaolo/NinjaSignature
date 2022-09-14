NINJASIGNATURE_HOME := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))


# Build:
.PHONY: build
build:
	@cpan Digest::SHA
	@cpan Getopt::Long
	@cpan Log::Log4perl
	@cpan Moose
	@cpan Moose::Role

.PHONY: build-dev
build-dev:
	make build
	@cpan Devel::Cover
	@cpan Perl::Tidy
	@cpan Test::Exception
	@cpan Test::MockObject
	@cpan Test::MockModule
	@cpan Test::More


# Install:
.PHONY: install
install:
	sudo ln -s $(NINJASIGNATURE_HOME)/ninjasignature.pl /usr/local/bin/ninjasignature

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
