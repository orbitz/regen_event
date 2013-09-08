export OCAMLPATH:=$(OCAMLPATH):../lib

CAMLP4=
OCAMLC_OPTS=-package regen_event
OCAMLOPT_OPTS=$(OCAMLC_OPTS)

NON_LIB_MODULES=simple_test.ml list_backend_test.ml

native_bin=$(NON_LIB_MODULES:%.ml=%.native)

byte_bin=$(NON_LIB_MODULES:%.ml=%.byte)

.PHONY: all native-code byte-code test clean

all: native-code byte-code

native-code: $(native_bin)

simple_test.native: simple_test.cmx

list_backend_test.native: list_backend_test.cmx

byte-code: $(byte_bin)

simple_test.byte: simple_test.cmo

list_backend_test.byte: list_backend_test.cmo

test: all
	./simple_test.native
	./simple_test.byte
	./list_backend_test.native
	./list_backend_test.byte

clean: extra_clean

extra_clean:
	-rm -f *.native *.byte *.cmx *.cmo *.o *.cmi

# Dependencies
include ../lib/Ocamlrules.mk.in
