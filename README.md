# NASM Tutorial

I wrote this tutorial back in 2010 to introduce people to x86 assembler. On a modern, 64-bit operating system
this code won't run - it was designed for 16-bit systems. You can install DosBox or your favorite emulator/hypervisor
like QEMU. If you go the latter route, you'll need to install an MSDOS-compatible operating system to use it. I
really recommend you check out DosBox.

You'll also need the open-source Netwide Assembler (NASM) and a linker. I'm using the public domain program
WarpLink for the tutorial. You can download a copy from the resources folder in this repository.

The file HELLO.ASM is a typical "Hello World" app. It introduces the basic concepts and syntax of assembly
language.

The file GOODBYE.ASM is a bit more complex, taking an argument from the command line and performing conditional
branching.

One day I will enhance this tutorial with more concepts, for those who really want to dabble in assembly language.
I may even introduce some 32-bit gui programming, but that is for another day.
