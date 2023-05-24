> The lovers moved to flee from heaven's tears

## Intro, Part 2, in which we learn about addressing memory.

Last time I said, “Before we begin in earnest, two things.” Here comes thing number two.

_Warning: this post contains frequent references to explicit hex, and may be inappropriate for readers under the age of 11h!_

Second, a word about how assembler works. You are no doubt aware that your computer has long-term storage (disks) and short-term storage (random access memory, or RAM). If we use an office allegory to describe a computer, we might say that the disks are like the filing cabinets in the back room: they can hold lots and lots of stuff, and are generally pretty well organized, but inconvenient. Constantly going to them to fetch new work or to put something away would be a chore. So, we tend to use them only when we need to grab something we plan to use soon or to put something away when we won't be using it for a good long while. RAM is like the in/out trays on my desk: I can stack all kinds of stuff there (though much less than I can put in the filing cabinets) and my work is quickly and easily accessible. The CPU is like my desktop, where all the work actually happens. To do some work, I have to take it from the trays and move it to the desktop, and to clear the desk for some other task I need to move what's on the desktop back to the trays. So, where in the CPU do we store this really temporary stuff while working on it?

### Registers

CPUs have built-in memory storage spaces called registers. In the intel x86 architecture, 16-bit general purpose registers go by the names AX, BX, CX and DX. Each 16-bit register can be broken into two parts, a high-order byte and a low-order byte. For register AX, these would be called AH and AL, respectively. The specific meanings of high- and low-order aren't too important right now, and the topic delves deep into ancient religious wars of CPU design. But suffice it to say that putting the 16-bit word `c725h` into register AX will load `c7h` into **AH** and `25h` into **AL**.

In modern, 32-bit CPUs, each 16-bit register is only half of one of the 32-bit registers, which bear the names EAX, EBX, ECX and EDX. There are other special purpose registers that we'll talk about as we move along, but you get the idea.

So writing an assembly language program is like shuffling paperwork around. You copy data into a register, you tell the CPU to process it, then you do something (or nothing, if you wish) with the result. Here is a simple set of instructions that you'll see frequently in assembler. We'll talk about what it does next time.

```nasm
1  ; These instructions are commonly found in DOS programs.
2                  mov     ax, 4c00h
3                  int     21h
```

### Segments

Another thing you must know is how DOS accesses memory. To mov (copy) data to or from RAM, you need an address. Since DOS uses 16-bit registers, the largest address it can work with is 16 bits long, so dos can address up to 65,536 (64k) bytes of RAM. That's it. A long time ago, 64k was a lot. Remember all the great programs we ran on the Atari 800 XL or Commodore 64? But as consumers demanded more from their applications, 64k became a barrier. DOS handles this by viewing memory as a series of _segments_, each 64kb in size. A program can contain many segments of code and data, so long as none of them exceeds 64kb.

To address memory, then, we require two registers: a special segment register for the segment address and a normal general purpose register for the offset within that segment. If the DS register, which points to a data segment, contains `24a0h` and we `mov 0fh` into register DX, then **DS:DX** refers to the 16th byte of that segment, written as `24a0:000fh`. If we later load DS with `4110h`, we'll find that **DS:DX** now points to `4110:000fh`. It's not too complicated, but it's up to the programmer to remember which segment he's using at any point in time. Fortunately, you need not know the exact addresses of your segments (DOS actually determines that at runtime, so there is no way you _could_ know as you're writing your source). In assembler, we use labels, friendly names, to refer to addresses. So, you may see code like the following to initialize the data segment register:

```nasm
4  ; Load the DS register with the address of the data segment.
5                  mov     ax, data        ; “data” is the address of our
6                  mov     ds, ax          ; data segment
```

### Stack

Finally, there is the stack. This is a handy little place in memory to put things temporarily, such as when you want to pass data from one procedure to another. We push data onto the stack to store it, and we pop data off of the stack to retrieve it. The stack is like that little cart with the clean plates at the head of a buffet line. The most recently cleaned plates are warm, damp and on the top of the stack, and the ones that have been there awhile and are much drier are at the bottom. When you take a plate off the top, you're taking the one that was most recently placed on the stack.

Data stacks work the same way. The topmost item is the most recently pushed data, the oldest data is at the bottom. Data is always popped in reverse order from how it was pushed onto the stack.

Of course, we all know what happens when you put too many plates in a stack on one of those carts. Bad, loud things happen. If we were to overfill our stack segment in our program, we could overwrite some other segment, or worse, some other program's segment. This could also lead to bad, loud things, so the intel CPU does a funny thing when it sets up the stack: it fills it backward, from the top down. You need to see this to get it…

Let's say that you decide to create a stack segment for your program that is only four bytes long (don't use such a small stack in real life). The SS register (stack segment) will contain the address of the beginning, or bottom, of the stack. The first byte would be at **SS:0h**, the second at **SS:1h**, the third at **SS:2h** and the fourth at **SS:3h**. The stack pointer (another register called SP) will point to the top of the stack, 4h.

“Wait!” you cry. “4h isn't in the stack segment because it's only four bytes long!”  You're right. What's at the address that SP is pointing to right now? We don't know for sure. “Isn't that dangerous?” you ask. Perhaps, but wait until you see how the thing comes off.

When we push a byte onto the stack, SP is _first decremented_, so now it points to 3h. Then the pushed data is copied to 3h. See? Everything is okay because we don't actually write to 4h, so we don't corrupt some other program's stuff. When we push a second byte, SP is decremented and the new data is written to 2h. When we pop the data off of the stack, the data that SP points to at 2h is copied and SP is incremented to point to 3h. But what if we try to push more than four bytes onto the stack? Well, consider that when the fourth byte is pushed, SP has been decremented four times, so it now points to 0h. Any attempt to decrement SP again will set the overflow flag in the flags register, and DOS will crash your program with a stack overflow error. Your program valiantly falls on its own sword to keep from doing bad things to other programs. Of course, there is nothing to keep you from popping the data at 4h before you've pushed anything onto the stack. Just expect really bad things to happen when you try to use that unknown value. It's best to not go there.

Why use the stack if it's so much potential trouble? Remember that programs love it, more than programmers love their buffets. Sometimes procedures pass parameters by the stack so that they can do things. After branching to another line of execution, the stack can act like a trail of breadcrumbs, helping your code to wend its way back to where it came from. Even if you never consciously use it, the services you request through DOS or BIOS interrupts will use the stack. Buck up, young padawan: you can't escape your destiny.

Now, then, you're all set to write your first program in assembly language…
