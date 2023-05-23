; goodbye.asm
; This variation on the 'Hello World' program expands upon the original
; a little by accepting a name from the command line and printing that 
; in the message. If no parameter is supplied, the program will use a
; default value. This one is written as a COM file, so it doesn't
; require linking.
; To assemble: nasm -o goodbye.com goodbye.asm
;
; Robert Ritter 
; 25 Apr 2010
; ----------------------------------------------------------------------
org 100h
; We set up a COM file by defining the address of the program location
; in memory, which will always be 100h. Then we jump to the start of 
; the code block.
;
                jmp     Start

; ----------------------------------------------------------------------
section .data
; DOS COM files don't use segmented memory. The whole program fits
; into a single 64KB block, so there's no need to worry about segments
; at all. The assembler still expects to find defined data and code
; sections, though, and it helps us to organize our source if we keep
; things compartmentalized like this.
;
beginMsg        db      'Goodbye, '
defaultMsg      db      'Mr. Chips'
endMsg          db      '!', 0dh, 0ah, '$'
endMsgLen       equ     $ - endMsg

; ----------------------------------------------------------------------
section .bss
; This section contains unintialized storage space. We allocate space
; here for data that we won't have until runtime. COM files don't
; require an explicit STACK section. The assembler will take care of
; the stack for us.
;
fullMsg         resb    1024    ; This is the message we will print.
                                ; We'll assemble it from parts and
                                ; copy each part into this memory area.

; ----------------------------------------------------------------------
section .code

Start:
; First we'll copy the beginning of the message, 'Goodbye,' to our
; allocated memory. The number of bytes to copy (the length of our
; data) goes into CX.
                mov     cx, defaultMsg - beginMsg
; The address of the data goes into SI (think Source Index) and the
; address of the allocated memory into DI (as in Destination Index.)
                mov     si, beginMsg
                mov     di, fullMsg
        rep     movsb   ; REP MOVSB copies CX bytes from SI to DI.
                        ; DI is automatically incremented.

; Next we'll copy the command line parameter into our allocated memory.
; When we start a program, DOS creates a data structure for it called
; the PSP (Program Segment Prefix) that loads ahead of it in the first
; 256 (100h) bytes of memory. (This is why the COM file has to point to
; address 100h to start.) The first 128 bytes of the PSP is "stuff," so
; we won't worry about that. The last half of the PSP contains the
; parameter string. Byte 80h contains the length of the string and the
; remaining bytes contain the parameter string terminated by a carriage
; return (0dh.)
                xor     cx, cx          ; Set CX to zero.
                mov     cl, [80h]       ; Put the parameter length
                                        ; into CL.
                cmp     cl, 0           ; Test CL to see if it's zero.
                jz      NoParam         ; If CL contains zero jump to
                                        ; another part of the program.
; If the JZ (Jump if Zero) wasn't executed, then the user ran the
; program with a command line parameter. CX now contains the number of
; bytes in the string, but the first byte is always a space, so we'll
; decrement CX and start copying the string from byte 82h. DI already
; points to the end of the last thing we copied to memory.
                dec     cx
                mov     si, 82h
        rep     movsb
                jmp     FinishString    ; Skip the NoParam part since
                                        ; there was a parameter.

NoParam:
; No parameter was given on the command line. We'll use the default
; goodbye message.
                mov     cx, endMsg - defaultMsg
                mov     si, defaultMsg
        rep     movsb

FinishString:
; Now we copy the last part of the message to memory.
                mov     cx, endMsgLen
                mov     si, endMsg
        rep     movsb

; Use the DOS service call to print the string that is in memory.
                mov     dx, fullMsg
                mov     ah, 09h
                int     21h

; Exit with no error code.
                mov     ax, 4c00h
                int     21h
