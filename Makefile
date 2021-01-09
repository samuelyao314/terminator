.PHONY:all skynet clean dev build test check

all: skynet build

PLAT="linux"
ifeq ($(shell uname), Darwin)
	PLAT="macosx"
endif


SKYNET_MAKEFILE=skynet/Makefile
$(SKYNET_MAKEFILE):
	git submodule update --init
skynet: | $(SKYNET_MAKEFILE)
	cd skynet && $(MAKE) $(PLAT) MYCFLAGS="-fno-omit-frame-pointer "

build:
	-mkdir $@
	cd build && cmake -DCMAKE_BUILD_TYPE=Debug .. && make

clean:
	-rm -rf deploy
	-rm -rf build
	-rm -rf lualib/3rd/*
	-rm -f luaclib/*so
	cd skynet && make clean


INSTALL_DIR = deploy/
INSTALL_SKYNET = ${INSTALL_DIR}/skynet

dev:
	python tools/deploy.py . deploy

test:
	python tools/unittest.py skynet/3rd/lua/lua lualib

check:
	luacheck --config .luacheckrc .

update:
	git submodule foreach git submodule update
