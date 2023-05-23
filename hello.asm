; hello.asm
; Demonstrates how to write an assembly program for DOS with NASM using
; the ubiquitous 'Hello World' string. To create an EXE file we'll
; first assemble an OBJ file then link it. I'm using the public domain
; linker WarpLink.
; To assemble: nasm -f obj hello.asm
; To link: warplink hello.obj
;
; Robert Ritter <rritter@centriq.com>
; 12 Apr 2010

; ----------------------------------------------------------------------
segment data
; DOS EXE files use segmented memory which allows them to address more
; than 64KB at a time. Here we define the data segment to store the
; message that we're going to print on the screen.
;
message         db      'Hello World', 0dh, 0ah, '$'

 ; ----------------------------------------------------------------------
segment code
; The code segment is where our program actually does stuff. Executable
; instructions go here. 
;
..start:
; First we need to do some housekeeping. Our program needs to know at
; what addresses its segments can be found. The Intel CPU contains some
; special registers just to hold this information, so we'll load them
; up now. Since we can't put addresses directly into these registers,
; we'll copy them to the AX general purpose register first.
                mov     ax, data
                mov     ds, ax          ; DS: data segment register
                mov     ax, stack
                mov     ss, ax          ; SS: stack segment register
                mov     sp, stackTop    ; SP: stack pointer register

; We're going to use a DOS service to write a string to the screen.
; The documentation for this service says that we have to terminate the
; string we want to print with a dollar sign (see how we did this in
; the data segment above) and we must put the address of the string
; into the DX register and call the service. DOS interrupt 21h provides
; all kinds of cool services. To use it we place the service ID in
; register AH and call INT 21h.
                mov     dx, message
                mov     ah, 09h
                int     21h

; We also use INT 21h to exit our program. The exit function is 4Ch,
; which goes into AH. The exit code that is used to report errors back
; to the operating system goes into AL. We'll just load both at the
; same time, then call INT 21h.
                mov     ax, 4c00h
                int     21h
