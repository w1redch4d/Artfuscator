ELVM_DIR=./elvm

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
        $(error Undefined $1$(if $2, ($2))$(if $(value @), \
                required by target `$@')))

ARCH ?= x64

ifeq ($(ARCH),x64)
    NASM_FORMAT = elf64
    LD_FLAG = elf_x86_64
else ifeq ($(ARCH),x86)
    NASM_FORMAT = elf32
    LD_FLAG = elf_i386
else
    $(error Unsupported architecture $(ARCH). Use ARCH=x86 or ARCH=x64.)
endif

%:
	@:$(call check_defined, IMG)
	mkdir -p build
	$(ELVM_DIR)/out/8cc -I$(ELVM_DIR)/libc -o build/$@.s -S $@.c
	$(ELVM_DIR)/out/elc -art build/$@.s > build/$@.art.nasm
	python3 -m artfuscator --arch $(ARCH) -i $(IMG) build/$@.art.nasm
	nasm -f $(NASM_FORMAT) -o build/$@.art.o build/$@.art.nasm
	mkdir -p dist
	ld -m $(LD_FLAG) --strip-all -o dist/$@.art build/$@.art.o

clean:
	rm -rf build
	rm -rf dist