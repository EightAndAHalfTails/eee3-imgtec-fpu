VHDL Floating-point Unit
========================

Project Overview
----------------

This project comprised the Third Year Group Project module for the Electronic and Electrical Engineering and the Electronic and Information Engineering courses at Imperial College.

The task set by Imagination Technologies was to design and verify a Floating Point Unit (FPU) in VHDL. Bit-equivalent (same inputs, same outputs) C++ versions of the entities also exist for verification purposes.

Build Process
-------------

Unfortunately, no makefile or other automated build system exists at the moment, so if you want to simulate or compile the design, you will have to include the relevent files into your simulator or synthesiser of choice yourself, resolving dependencies manually.

Specification
-------------

The FPU implements the following operations and is currently unpipelined with one cycle of latency (clock data in, clock result out):

Operation | Formula
----------|--------
`nop`| No operation
`mul`| `a*b`
`add`| `a+b`
`sub`| `a-b`
`fma`| `ab+c`
`div`| `a/b`
`dot2`| `a*c + b*d`
`dot3`| `a*d + b*e + c*f`
`sqrt`| `sqrt(a)`
`isqrt`| `1/sqrt(a)`
`dist2`| `sqrt(a*a + b*b)`
`dist3`| `sqrt(a*a + b*b + c*c)`
`norm`| `a/sqrt(a*a + b*b + c*c)`
