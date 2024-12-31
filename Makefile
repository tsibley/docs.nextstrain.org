# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line, and also
# from the environment for the first three.
SPHINXOPTS    ?=
SPHINXBUILD   ?= sphinx-build
BUILDDIR      ?= build
SOURCEDIR     = src

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help help-docker Makefile

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

# Generating --ignore options from .gitignore means that src/fetch-docs.py,
# which runs on build and produces files in src/, doesn't trigger an endless
# loop of autobuilds.  The syntax of .gitignore patterns is not actually
# identical to sphinx-autobuild's --ignore patterns (which use Python's
# fnmatch(), where "*" means something other than a normal glob, for example),
# but our usage is limited enough for this to work as much as necessary.
livehtml:
	sphinx-autobuild -b html $(patsubst %,--ignore "**%",$(file < .gitignore)) "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.ONESHELL:
docker-html:
	set -euox
	docker build -t nextstrain-docs-builder \
	--network=host \
	--build-arg UID=$(shell id -u) \
	--build-arg GID=$(shell id -g) \
	.
	docker run -it --rm \
	--name=nextstrain-docs-builder-$(shell date +%s) \
	--init \
	--user=$(shell id -u):$(shell id -g) \
	--volume=$(shell pwd):/home/user/src \
	--workdir=/home/user/src \
	--env 'TERM=xterm-256colors' \
	nextstrain-docs-builder
