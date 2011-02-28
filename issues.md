# Progress

* + Autoconfigure works
* + Configure works
* + Host compilation works
* + Host linking works
* + Target compilation works
* - Target linking fails
* ? Bundling
* ? Execution



# Todos



# Hurdles

## Compile and Link Binary location and filenames

### Problem
Just setting the host variable and then let the binaries filename
guess like `$HOST-gcc` does not work for the iOS toolchain, because
the binary filenames are cctually named like `$HOST-gcc-$VERSION`.

### Solution
Set them correctly.


## Undetermined endianness

### Problem
The endianness can not be determined by the autoconfigure script and
is also not set with a default value.

### Solution
As the arm-apple-darwin iOS platform uses little-endian, set the
big-endian autoconfigure flag to `no`:

    erl_xcomp_bigendian=no


## Not available -m32 flag

### Problem
The `-m32` flag is usually set to explicitly express that the system
should be build for a 32-bit architecture. But the iOS GCC compiler
for ARM does not support this flag (yet, as all ARM chips are supposed
to not have 64 bit support).

### Solution
Apply patch to not create the `-m32` flag in configure files. (See
patch file).


## bp_sched2ix Not defined

### Problem
Issues while compiling:
 * erl_init.o
 * erl_bif_trace.o
 * erl_trace.o
 * bif.o
 * erl_process.o
 * erl_nif.o
 * beam_emu.o
 * beam_bif_load.o
 * beam_debug.o

beam/beam_bp.h:147: warning: inline function ‘bp_sched2ix’ declared but never defined

This leads to:

    Undefined symbols:
      "_bp_sched2ix", referenced from:
            _load_nif_2 in erl_nif.o
            ld: symbol(s) not found
            collect2: ld returned 1 exit status
            make[3]: ***
      [/Users/uwe/dev/erlang-embedded/otp_src_R14B01/bin/arm-apple-darwin10/beam]
      Error 1
      make[2]: *** [opt] Error 2
      make[1]: *** [opt] Error 2
      make: *** [emulator] Error 2

Might be, that SMP is partly believed to be activated and implemented,
but actually isn't. 

### Solution
Try to really unset using SMP
