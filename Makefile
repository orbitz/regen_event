.PHONY: all clean test

all:
	$(MAKE) -C lib

test: all
	$(MAKE) -C lib test
	$(MAKE) -C tests test

clean:
	$(MAKE) -C lib clean

