CAMLP4=
OCAMLC_OPTS=-package regen_event
OCAMLOPT_OPTS=$(OCAMLC_OPTS)

TEST_MODULES=\
	simple_test.ml list_backend_test.ml


.PHONY: all test

all: test

# Dependencies
include ../lib/Ocamlrules.mk.in
