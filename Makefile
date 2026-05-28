SOURCES_DIR ?= ../sources
DONNA ?= build/bin/donna
BOOTSTRAP_DONNA ?= build/bin/donna-bootstrap
QBE_INSTALL ?= /usr/local
CI_PATH := $(CURDIR)/scripts/ci-bin:$(PATH)

.PHONY: build bootstrap check test smoke self-host ci release-artifacts install-qbe clean

build: bootstrap

bootstrap:
	./scripts/build-from-sources.sh "$(SOURCES_DIR)"

check: build
	ulimit -s 32768 || true; $(DONNA) build

test: build
	ulimit -s 32768 || true; $(DONNA) test

smoke:
	PATH="$(CI_PATH)" DONNA="$(DONNA)" ./scripts/smoke-fresh-project.sh

self-host: build
	cp "$(DONNA)" "$(BOOTSTRAP_DONNA)"
	rm -f "$(DONNA)"
	rm -rf build/dev build/packages build/test
	ulimit -s 32768 || true; PATH="$(CI_PATH)" "$(BOOTSTRAP_DONNA)" build
	test -x "$(DONNA)"
	cp "$(DONNA)" "$(BOOTSTRAP_DONNA)"
	rm -f "$(DONNA)"
	rm -rf build/dev build/packages build/test
	ulimit -s 32768 || true; PATH="$(CI_PATH)" "$(BOOTSTRAP_DONNA)" build
	test -x "$(DONNA)"

ci: self-host
	ulimit -s unlimited || ulimit -s 32768 || true; PATH="$(CI_PATH)" "$(DONNA)" test
	PATH="$(CI_PATH)" DONNA="$(DONNA)" ./scripts/smoke-fresh-project.sh
	"$(DONNA)" version

release-artifacts: self-host
	./scripts/release.sh

install-qbe:
	./scripts/install-qbe.sh "$(QBE_INSTALL)"

clean:
	rm -rf build docs
