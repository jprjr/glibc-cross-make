
OUTPUT = $(CURDIR)/output

BINUTILS_SRCDIR = BINUTILS_SRCDIR_not_set
GCC_SRCDIR = GCC_SRCDIR_not_set
GLIBC_SRCDIR = GLIBC_SRCDIR_not_set

GCC_CONFIG_FOR_TARGET = 
COMMON_CONFIG = 
GCC_CONFIG = 
TOOLCHAIN_CONFIG = 

-include config.mak

ifneq ($(findstring fdpic,$(TARGET)),)
GCC_CONFIG_FOR_TARGET += --enable-fdpic
endif

ifneq ($(filter x86_64%x32,$(TARGET)),)
GCC_CONFIG_FOR_TARGET += --with-abi=x32
endif

ifneq ($(findstring powerpc64,$(TARGET)),)
GCC_CONFIG_FOR_TARGET += --with-abi=elfv2
endif

ifneq ($(findstring mips64,$(TARGET))$(findstring mipsisa64,$(TARGET)),)
ifneq ($(findstring n32,$(TARGET)),)
GCC_CONFIG_FOR_TARGET += --with-abi=n32
else
GCC_CONFIG_FOR_TARGET += --with-abi=64
endif
endif

ifneq ($(filter %sf,$(TARGET)),)
GCC_CONFIG_FOR_TARGET += --with-float=soft
endif

ifneq ($(filter %hf,$(TARGET)),)
GCC_CONFIG_FOR_TARGET += --with-float=hard
endif


MAKE += MULTILIB_OSDIRNAMES=
MAKE += INFO_DEPS= infodir=
MAKE += ac_cv_prog_lex_root=lex.yy.c

FULL_TOOLCHAIN_CONFIG = --enable-languages=c,c++ \
	$(GCC_CONFIG_FOR_TARGET) \
	$(COMMON_CONFIG) $(GCC_CONFIG) $(TOOLCHAIN_CONFIG) \
	--disable-werror \
	--target=$(TARGET) --build=$(BUILD) --host=$(BUILD) --prefix= \
	--libdir=/lib --disable-multilib \
	--with-sysroot=$(SYSROOT) \
	--enable-tls \
	--disable-libmudflap --disable-libsanitizer \
	--disable-gnu-indirect-function \
	--disable-libmpx \
	--enable-libstdcxx-time \

FULL_GLIBC_CONFIG = $(GLIBC_CONFIG) \
	--prefix= --build=$(BUILD) --target=$(TARGET) --host=$(TARGET) \
	--enable-kernel=3.2 \
	--disable-profile \
	--enable-add-ons \
	--with-headers=$(CURDIR)/obj_sysroot/include \
	libc_cv_forced_unwind=yes \
	libc_cv_c_cleanup=yes \
	libc_cv_ssp=no libc_cv_ssp_strong=no

ifneq ($(NATIVE),)
HOST:=$(TARGET)
endif

ifeq ($(HOST),)
SYSROOT = /$(TARGET)
FULL_TOOLCHAIN_CONFIG += --with-build-sysroot=$(CURDIR)/obj_sysroot
else
SYSROOT = /
FULL_TOOLCHAIN_CONFIG += --host=$(HOST)
GLIBC_VARS = 
endif

ifeq ($(TARGET),)

all:
	@echo TARGET must be set.
	@exit 1

install: all

else

all: glibc toolchain

install: install-glibc install-toolchain

glibc: glibc-stage2

toolchain: gcc-stage3

binutils: obj_toolchain/binutils/.lc_built

gcc-stage1: obj_toolchain/gcc/.lc_stage1_built

glibc-stage1: obj_toolchain/glibc/.lc_stage1_built

gcc-stage2: obj_toolchain/gcc/.lc_stage2_built

glibc-stage2: obj_toolchain/glibc/.lc_stage2_built

gcc-stage3: obj_toolchain/gcc/.lc_stage3_built

.PHONY: all glibc toolchain install-glibc install-toolchain clean

src_binutils: | $(BINUTILS_SRCDIR)
	ln -sf $(BINUTILS_SRCDIR) $@

src_gcc: | $(GCC_SRCDIR)
	ln -sf $(GCC_SRCDIR) $@

src_glibc: | $(GLIBC_SRCDIR)
	ln -sf $(GLIBC_SRCDIR) $@

ifneq ($(GMP_SRCDIR),)
src_toolchain: src_gmp
src_gmp: | $(GMP_SRCDIR)
	ln -sf "$(GMP_SRCDIR)" $@
endif

ifneq ($(MPC_SRCDIR),)
src_toolchain: src_mpc
src_mpc: | $(MPC_SRCDIR)
	ln -sf "$(MPC_SRCDIR)" $@
endif

ifneq ($(MPFR_SRCDIR),)
src_toolchain: src_mpfr
src_mpfr: | $(MPFR_SRCDIR)
	ln -sf "$(MPFR_SRCDIR)" $@
endif

ifneq ($(ISL_SRCDIR),)
src_toolchain: src_isl
src_isl: | $(ISL_SRCDIR)
	ln -sf "$(ISL_SRCDIR)" $@
endif

src_toolchain: src_binutils src_gcc
	rm -rf $@ $@.tmp
	mkdir $@.tmp
	mkdir $@.tmp/binutils
	mkdir $@.tmp/gcc
	cd $@.tmp/binutils && ln -sf ../../src_binutils/* .
	cd $@.tmp/gcc && ln -sf ../../src_gcc/* .
	$(if $(GMP_SRCDIR),cd $@.tmp/gcc && ln -sf ../../src_gmp gmp)
	$(if $(MPC_SRCDIR),cd $@.tmp/gcc && ln -sf ../../src_mpc mpc)
	$(if $(MPFR_SRCDIR),cd $@.tmp/gcc && ln -sf ../../src_mpfr mpfr)
	$(if $(ISL_SRCDIR),cd $@.tmp/gcc && ln -sf ../../src_isl isl)
	mv $@.tmp $@

obj_%:
	mkdir -p $@

obj_sysroot/include:
	mkdir -p $@

obj_sysroot/usr: | obj_sysroot
	ln -sf . $@

obj_sysroot/lib64: | obj_sysroot
	ln -sf lib $@

obj_toolchain/binutils/.lc_configured: | src_toolchain
	mkdir -p obj_toolchain/binutils
	cd obj_toolchain/binutils && ../../src_toolchain/binutils/configure $(FULL_TOOLCHAIN_CONFIG)
	touch $@

obj_toolchain/binutils/.lc_built: | obj_toolchain/binutils/.lc_configured obj_sysroot
	cd obj_toolchain/binutils && $(MAKE) MAKE="$(MAKE)"
	cd obj_toolchain/binutils && $(MAKE) MAKE="$(MAKE)" DESTDIR=$(CURDIR)/obj_sysroot install
	touch $@

obj_toolchain/gcc/.lc_configured: | obj_toolchain/binutils/.lc_built obj_kernel_headers/.lc_built
	mkdir -p obj_toolchain/gcc
	cd obj_toolchain/gcc && PATH="$(CURDIR)/obj_sysroot/bin:$(PATH)" ../../src_toolchain/gcc/configure $(FULL_TOOLCHAIN_CONFIG)
	touch $@

obj_toolchain/gcc/.lc_stage1_built: | obj_toolchain/gcc/.lc_configured obj_sysroot/usr
	cd obj_toolchain/gcc && PATH="$(CURDIR)/obj_sysroot/bin:$(PATH)" $(MAKE) MAKE="$(MAKE)" all-gcc
	cd obj_toolchain/gcc && PATH="$(CURDIR)/obj_sysroot/bin:$(PATH)" $(MAKE) MAKE="$(MAKE)" DESTDIR=$(CURDIR)/obj_sysroot install-gcc
	touch $@

obj_toolchain/glibc/.lc_configured: | obj_toolchain/gcc/.lc_stage1_built src_glibc
	mkdir -p obj_toolchain/glibc
	cd obj_toolchain/glibc && PATH="$(CURDIR)/obj_sysroot/bin:$(PATH)" ../../src_glibc/configure $(FULL_GLIBC_CONFIG)
	touch $@

obj_toolchain/glibc/.lc_stage1_built: | obj_toolchain/glibc/.lc_configured
	cd obj_toolchain/glibc && PATH="$(CURDIR)/obj_sysroot/bin:$(PATH)" $(MAKE) MAKE="$(MAKE)" DESTDIR=$(CURDIR)/obj_sysroot install-bootstrap-headers=yes install-headers
	cd obj_toolchain/glibc && PATH="$(CURDIR)/obj_sysroot/bin:$(PATH)" $(MAKE) MAKE="$(MAKE)" csu/subdir_lib
	mkdir -p $(CURDIR)/obj_sysroot/lib
	cd obj_toolchain/glibc && install csu/crt1.o csu/crti.o csu/crtn.o $(CURDIR)/obj_sysroot/lib
	PATH="$(CURDIR)/obj_sysroot/bin:$(PATH)" $(TARGET)-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o $(CURDIR)/obj_sysroot/lib/libc.so
	touch $(CURDIR)/obj_sysroot/include/gnu/stubs.h
	touch $@

obj_toolchain/gcc/.lc_stage2_built: | obj_toolchain/glibc/.lc_stage1_built
	cd obj_toolchain/gcc && PATH="$(CURDIR)/obj_sysroot/bin:$(PATH)" $(MAKE) MAKE="$(MAKE)" all-target-libgcc
	cd obj_toolchain/gcc && PATH="$(CURDIR)/obj_sysroot/bin:$(PATH)" $(MAKE) MAKE="$(MAKE)" DESTDIR=$(CURDIR)/obj_sysroot install-target-libgcc
	touch $@

obj_toolchain/glibc/.lc_stage2_built: | obj_toolchain/gcc/.lc_stage2_built
	cd obj_toolchain/glibc && PATH="$(CURDIR)/obj_sysroot/bin:$(PATH)" $(MAKE) MAKE="$(MAKE)"
	cd obj_toolchain/glibc && PATH="$(CURDIR)/obj_sysroot/bin:$(PATH)" $(MAKE) MAKE="$(MAKE)" DESTDIR=$(CURDIR)/obj_sysroot install
	find obj_sysroot -name '*.info*' -print -delete
	touch $@

obj_toolchain/gcc/.lc_stage3_built: | obj_toolchain/glibc/.lc_stage2_built
	cd obj_toolchain/gcc && PATH="$(CURDIR)/obj_sysroot/bin:$(PATH)" $(MAKE) MAKE="$(MAKE)"
	cd obj_toolchain/gcc && PATH="$(CURDIR)/obj_sysroot/bin:$(PATH)" $(MAKE) MAKE="$(MAKE)" DESTDIR=$(CURDIR)/obj_sysroot install
	touch $@

install-glibc: | obj_toolchain/glibc/.lc_stage2_built
	cd obj_toolchain/glibc && PATH="$(CURDIR)/obj_sysroot/bin:$(PATH)" $(MAKE) MAKE="$(MAKE)" DESTDIR=$(DESTDIR)$(OUTPUT)$(SYSROOT) install-headers
	cd obj_toolchain/glibc && PATH="$(CURDIR)/obj_sysroot/bin:$(PATH)" $(MAKE) MAKE="$(MAKE)" DESTDIR=$(DESTDIR)$(OUTPUT)$(SYSROOT) install
	find $(DESTDIR)$(OUTPUT) -name '*.info*' -print -delete
	find $(DESTDIR)$(OUTPUT) -name 'dir' -print -delete

install-toolchain: | obj_toolchain/gcc/.lc_stage3_built obj_toolchain/binutils/.lc_built
	cd obj_toolchain/binutils && PATH="$(CURDIR)/obj_sysroot/bin:$(PATH)" $(MAKE) MAKE="$(MAKE)" DESTDIR=$(DESTDIR)$(OUTPUT) install
	cd obj_toolchain/gcc && PATH="$(CURDIR)/obj_sysroot/bin:$(PATH)" $(MAKE) MAKE="$(MAKE)" DESTDIR=$(DESTDIR)$(OUTPUT) install
	find $(DESTDIR)$(OUTPUT) -name '*.info*' -print -delete
	find $(DESTDIR)$(OUTPUT) -name 'dir' -print -delete
	ln -sf $(TARGET)-gcc $(DESTDIR)$(OUTPUT)/bin/$(TARGET)-cc

ifneq ($(LINUX_SRCDIR),)
TARGET_ARCH = $(firstword $(subst -, ,$(TARGET)))
TARGET_ARCH_MANGLED = $(patsubst i%86,x86,$(patsubst aarch64%,arm64%,$(TARGET_ARCH)))
LINUX_ARCH_LIST = $(sort $(notdir $(wildcard $(LINUX_SRCDIR)/arch/*)))
LINUX_ARCH = $(firstword $(foreach a,$(LINUX_ARCH_LIST),$(findstring $(a),$(TARGET_ARCH_MANGLED))))
ifneq ($(LINUX_ARCH),)
all: kernel-headers
install: install-kernel-headers
kernel-headers: | obj_kernel_headers/.lc_built
src_kernel_headers: | $(LINUX_SRCDIR)
	ln -sf "$(LINUX_SRCDIR)" $@
obj_kernel_headers/.lc_built: | src_kernel_headers
	mkdir -p $(CURDIR)/obj_kernel_headers/staged
	cd src_kernel_headers && $(MAKE) ARCH=$(LINUX_ARCH) O=$(CURDIR)/obj_kernel_headers INSTALL_HDR_PATH=$(CURDIR)/obj_kernel_headers/staged headers_install
	find obj_kernel_headers/staged/include '(' -name .install -o -name ..install.cmd ')' -exec rm {} +
	mkdir -p $(CURDIR)/obj_sysroot/include
	cp -R obj_kernel_headers/staged/include/* $(CURDIR)/obj_sysroot/include/
	touch $@
install-kernel-headers: | obj_kernel_headers/.lc_built
	mkdir -p $(DESTDIR)$(OUTPUT)$(SYSROOT)/include
	cp -R obj_kernel_headers/staged/include/* $(DESTDIR)$(OUTPUT)$(SYSROOT)/include
endif
endif

endif

clean:
	rm -rf src_* obj_*
