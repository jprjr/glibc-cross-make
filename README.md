glibc-cross-make
===============

This is a fork of musl-cross-make, but for building glibc-targeting
cross compilers.

Features:

- Single-stage GCC build, used to build both glibc libc and its own
  shared target libs depending on libc.

- No hard-coded absolute paths; resulting cross compilers can be
  copied/moved anywhere.

- Ability to build multiple cross compilers for different targets
  using a single set of patched source trees.

- Nothing is installed until running `make install`, and the
  installation location can be chosen at install time.

- Automatic download of source packages, including GCC prerequisites
  (GMP, MPC, MPFR), using https and checking hashes.

- Automatic patching with canonical glibc support patches and patches
  which provide bug fixes and features glibc depends on for some arch
  targets.


Usage
-----

The build system can be configured by providing a `config.mak` file in
the top-level directory. The only mandatory variables  `TARGET` and `BUILD`, which
should contain a gcc target tuple (such as `i486-linux-musl`), but many
more options are available. See the provided `config.mak.dist` and
`presets/*` for examples.

To compile, run `make`. To install to `$(OUTPUT)`, run `make install`.

The default value for `$(OUTPUT)` is output; after installing here you
can move the cross compiler toolchain to another location as desired.



Supported `TARGET`s
-------------------

The following is a non-exhaustive list of `$(TARGET)` tuples that are
believed to work:

- `i*86-linux-gnu`
- `x86_64-linux-gnu`


Why this?
---------

For setting up real cross-compilers targetting embedded platforms,
it might be better to look
into crosstool-ng. This is a real hacked-up version of musl-cross-make,
I don't think canadian-cross builds will work, you have to specify
your build machine manually, etc. I'm just using this for glibc on
x86_64 and not much else.

Hopefully this can be useful for producing binaries for Linux. The
default glibc used is 2.19, which is the version found on Debian Jessie
and Ubuntu Trusty. Binaries produced with this toolchain will (hopefully)
work on these distributions as well as later releases.

When I want to produce a binary, I usually produce a static binary
compiled against musl. However, some software still fails to compile
against musl - this lets me produce a static-ish binary (bundle up
the libs, but still use libc.so at runtime).

As of right now, this hasn't been tested a heck of a whole lot. Use
with caution.


