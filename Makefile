LIBS := build/libgetargs.a build/libgetargs.so

.PHONY: all
all: $(LIBS)

build/libgetargs.a: main.odin
	odin build . -build-mode:object -o:speed -out:build/getargs
	ar -crs build/libgetargs.a build/getargs.o
	rm build/getargs.o

build/libgetargs.so: main.odin
	odin build . -build-mode:shared -o:speed -out:build/libgetargs

.PHONY: clean
clean:
	find build -type f \( -name '*.so' -o -name '*.a' \) -delete
