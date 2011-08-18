uname_S := $(shell sh -c 'uname -s 2>/dev/null || echo not')

EIO_CFLAGS=-D_GNU_SOURCE

ifeq (SunOS,$(uname_S))
EIO_CONFIG_H=config_sunos.h
EIO_CFLAGS+= -D__EXTENSIONS__
endif

ifeq (Darwin,$(uname_S))
EIO_CONFIG_H=config_darwin.h
endif

ifeq (FreeBSD,$(uname_S))
EIO_CONFIG_H=config_freebsd.h
endif

ifeq (Linux,$(uname_S))
EIO_CONFIG_H=config_linux.h
endif

ifdef EIO_CONFIG_H
EIO_CFLAGS+= -DEIO_CONFIG_H=\"$(EIO_CONFIG_H)\"
endif

eio.o: eio.c
	$(CC) $(CFLAGS) $(EIO_CFLAGS) -c $< -o $@

clean:
	-rm -f eio.o
