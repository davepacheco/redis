# Top level makefile, the real shit is at src/Makefile

.PHONY: install

.DEFAULT:
	cd src && $(MAKE) $@

all:
	cd src && $(MAKE) $@

test:
	cd src && $(MAKE) $@

clean:
	cd src && $(MAKE) $@
	cd deps/hiredis && $(MAKE) $@
	cd deps/linenoise && $(MAKE) $@

src/help.h:
	@./utils/generate-command-help.rb > $@
