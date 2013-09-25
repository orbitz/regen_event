CAMLP4=
OCAMLC_OPTS=-package core,async,async_core
OCAMLOPT_OPTS=$(OCAMLC_OPTS)

LIB_MODULES=regen_event.ml regen_event_list_backend.ml
NON_LIB_MODULES=

BYTE_TARGETS=regen_event.cma
NATIVE_TARGETS=regen_event.cmxa

.PHONY: all test

all: native-code byte-code

install: all
	ocamlfind install regen_event META regen_event.cmxa regen_event.cma regen_event.a *.cmx *.cmi *.mli

test:

# Dependencies
include ../Ocamlrules.mk.in
