#
# Makefile for ansi-sys
#

RUBY=ruby
RDOC=rdoc
SETUP=setup.rb
VERSION := $(shell ruby -Ilib -ransisys -e 'puts AnsiSys::VERSION::STRING')
PKGNAME= ansi-sys
ardir=.

# wrappers for setup.rb
.PHONY: check
check: spec

.PHONY: test
test:
	$(RUBY) $(SETUP) test

.PHONY: spec
spec:
	$(RUBY) $(SETUP) spec

.PHONY: install .config
install:
	$(RUBY) $(SETUP) $@

.config: config
.PHONY: config
config:
	$(RUBY) $(SETUP) $@

.PHONY: setup
setup:
	$(RUBY) $(SETUP) $@

# commit the changes
.PHONY: commit
commit: .svn
	log=`$(RUBY) -e 'print File.open("ChangeLog").read.split(/^$$/,2)[0]'`;\
	ver=`echo "$$log" | $(RUBY) -ne 'print if $$_.gsub!(/^- \\((\\d+\\.\\d+\\.\\d+)\\).*/, "\\\\1")'`;\
	if [ -n "$$ver" ] && [ "$$ver" != "$(VERSION)" ]; then \
		echo '*** Version in ChangeLog does not match the library version';\
		exit 1;\
	fi && \
	svn commit -m "$$log" && \
	echo "$$log" &&\
	if [ -n "$$ver" ]; then \
		cur_repo=`svn info | grep URL: | cut -f2 -d\ `;\
		tag_repo=`echo $$cur_repo | sed 's:/trunk/:/tags/:'`-$(VERSION); \
		echo "Tagging to $$tag_repo"; \
		svn remove -m "$$log" $$tag_repo 2>/dev/null ; \
		svn cp -m "$$log" $$cur_repo $$tag_repo && \
		echo Svn tag made at $$tag_repo; \
	fi

