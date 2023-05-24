>But thunder interrupted all their fears

## Writing your first program, HELLO.EXE

Now that you're ready to begin writing, we'll dig right in. Here is our first heavily annotated program, `hello.exe`.

Open up your DOSBox and change to the SOURCE directory.
```
cd source
```
Run editv with a new file, hello.asm.
```
editv hello.asm
```
I strongly advise you to turn on line numbering. You can do this by pressing **CTRL** followed by **B**, or you can just select the **Options** menu with **Alt-O**, scroll down to **Line Numbers** and press **Enter**.

We begin with comments. If you've ever read a book on programming, it has probably emphasized the need for good comments. In assembler, comments are even _more_ important because the language syntax is so terse. A comment begins with a semicolon and continues to the end of the line of text.

```nasm
1  ; hello.asm
2  ; Demonstrates how to write an assembly program for DOS with NASM using
3  ; the ubiquitous 'Hello World' string. To create an EXE file we'll
4  ; first assemble an OBJ file then link it. I'm using the public domain
5  ; linker WarpLink.
6  ; To assemble: nasm -f obj hello.asm
7  ; To link: warplink hello.obj
8  ;
9  ; Robert Ritter <rritter@centriq.com>
10 ; 12 Apr 2010
11 
```

Remember that DOS addresses memory in segments. The first thing we'll need to do is reserve some memory for these segments. Since this program doesn't work with a lot of data, our data segment is pretty small. It defines a label, **message**, that will be the memory address of the first byte of the message that we're going to print out. The **db** (define byte) operator identifies a sequence of bytes that make up our data. There is also a **dw** (define word) for 16-bit values, and **dd** (define double word) for 32-bit values. Most of the time you'll probably just treat data as a sequence of bytes, so you'll likely use db more than the others.

You may have noticed the characters that follow the obvious string, “Hello World.” If we want to advance our output to the next line, we must insert a newline character. This is like pressing the enter key on a keyboard. In high-level languages like C we use a string like “\n” to represent a newline, but in DOS we are required to use a two-byte sequence: **0dh** (carriage return) and **0ah** (linefeed). The dollar sign character is a terminator that marks the end of the string. Not all strings must be terminated with a dollar sign, but the DOS printing service that we're going to use requires it.

Notice that the characters that make up a string are enclosed in quotes. Double or single quotes, it makes no difference. Those characters outside the quotes are treated as literal bytes.

```nasm
12 ; ----------------------------------------------------------------------
13 segment data
14 ; DOS EXE files use segmented memory which allows them to address more
15 ; than 64KB at a time. Here we define the data segment to store the
16 ; message that we're going to print on the screen.
17 ;
18 message         db      'Hello World', 0dh, 0ah, '$'
19
```

The next thing that we want to do is reserve some memory for our stack segment. The **resb** (reserve byte) operator is used to set aside an uninitialized piece of memory of a given size. There is also a **resw** (reserve word) for 16-bit values and **resd** (reserve double word) for 32-bit values. We're going to allocate a 64-byte hunk'o'ram for the stack and set the label **stackTop** to point to the address immediately following the stack. For more info on how the stack works, see the previous tutorial.

```nasm
20 ; ----------------------------------------------------------------------
21 segment stack stack
22 ; The stack is used as temporary storage for values during the
23 ; program's execution. Sometimes we use it in our code, and sometimes
24 ; DOS uses it, especially when we call DOS interrupts. We'll set up a
25 ; small but serviceable stack for this program since we're going to be
26 ; calling on DOS services.
27 ;
28                 resb    64
29 stackTop        ; The label 'stackTop' is the address of the end (top)
30                 ; of the stack. We'll need this to initialize the
31                 ; stack pointer in the CPU.
32
```

The code segment is where the cool stuff happens. Remember that a DOS EXE file may have more than one code segment to get around that pesky 64kb barrier we discussed last time. Though multiple code segments are allowed, only one can be the actual entry point of our program. This is defined with a special label, **..start**. Note that I used a colon at the end of this label. A label may end with a colon, but this is not required. You may find code examples that are pretty inconsistent on the use of colons in labels. Even examples in the official NASM documentation waffle a little on this. Personally, I choose to use a colon when the label refers to a block of code, and to forgo the colon when the label refers to data. Remember, though, that to the assembler they're all just addresses.

We're giving the `mov` operator a real workout here. The instruction,
```
mov dest, src
```
tells the assembler to copy the data at `src` into `dest`. Yes, it goes right to left, but you get used to it pretty quickly. In this instance, we're loading segment addresses into their respective CPU registers. Since we can't copy immediate data directly into a segment register, we'll use AX for temporary storage.

```nasm
33 ; ----------------------------------------------------------------------
34 segment code
35 ; The code segment is where our program actually does stuff. Executable
36 ; instructions go here. 
37 ;
38 ..start:
39 ; First we need to do some housekeeping. Our program needs to know at
40 ; what addresses its segments can be found. The Intel CPU contains some
41 ; special registers just to hold this information, so we'll load them
42 ; up now. Since we can't put addresses directly into these registers,
43 ; we'll copy them to the AX general purpose register first.
44                 mov     ax, data
45                 mov     ds, ax          ; DS: data segment register
46                 mov     ax, stack
47                 mov     ss, ax          ; SS: stack segment register
48                 mov     sp, stackTop    ; SP: stack pointer register
49
```

Now we're going to call on DOS to print our message on the screen. DOS and the system BIOS have several services that they offer to our programs. These are accessed by triggering an interrupt with the `int` instruction. Each service has its own requirements, so we need to look up the particular service we want in our handy DOS Developer's Guide to properly use it. The DOS service we're using here is service `09h` of the general purpose interrupt `21h`. To use it, we place the address of a dollar-sign-terminated string into register DX, place the service ID `09h` into register AH, then call interrupt `21h`.

```nasm
50 ; We're going to use a DOS service to write a string to the screen.
51 ; The documentation for this service says that we have to terminate the
52 ; string we want to print with a dollar sign (see how we did this in
53 ; the data segment above) and we must put the address of the string
54 ; into the DX register and call the service. DOS interrupt 21h provides
55 ; all kinds of cool services. To use it we place the service ID in
56 ; register AH and call INT 21h.
57                 mov     dx, message
58                 mov     ah, 09h
59                 int     21h
60
```

Finally, we exit the program. We'll use service `4ch` of DOS interrupt `21h`. If you have a specific exit code (for example, to signal an error) you place it into register AL. Just as before, we put the service ID into AH and call the interrupt. Since we have no error condition, we'll do a clean exit. Here we load AL and AH at the same time by putting `4c00h` into AX.

```nasm
61 ; We also use INT 21h to exit our program. The exit function is 4Ch,
62 ; which goes into AH. The exit code that is used to report errors back
63 ; to the operating system goes into AL. We'll just load both at the
64 ; same time, then call INT 21h.
65                 mov     ax, 4c00h
66                 int     21h
67 
```

You have just written a program in assembly language. Save the file and exit editv. Assemble the file with NASM:
```
nasm -f obj hello.asm
```
This will create an object file suitable for linking into a DOS EXE. Link the file with warplink:
```
warplink hello.obj
```
This creates the file **hello.exe**. Notice that I included these instructions in the comments at the top of the source file. This is useful if you come back to the program at a later time and want to make changes. Now run your program and bask in the warmth of the knowledge that you have made this CPU do your explicit bidding. A little bit more of this, and you'll be ready for live minions.

Next time, we'll pass command-line parameters into our program, and we'll shake things up a bit with the DOS COM file format.
