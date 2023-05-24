> Assembled 'neath a dark, foreboding sky

## Intro, Part 1, in which we assemble our tools.

As promised, a little DOS and Linux assembly language tutorial in several verses for your consideration. Mostly DOS
though, for that is where my dark past lies: but a little Linux is good for the soul (and the understanding.) Before
we begin in earnest, two things:

First, assemble your “a” team, the tools you will need to code along with me. Since I work on Mac, Linux and Windows
platforms, I find great comfort in the familiarity of a singular environment across all machines that I (might) happen
to be writing code on at the moment. For this, I use [DOSBox,](https://www.dosbox.com/) a great little DOS + x86
emulator. It may have been primarily designed for running classic games like Wolfenstein or EGA Trek, but it makes for
a pretty decent development platform, too.

To write your code, you'll need a text editor. Alas, a good dos text editor for writing assembler is only a pipe dream
(this used to not be the case, but I can't find my old tools anymore.) 
[Editv,](https://vetusware.com/download/EDITV%204.1/?id=12301) however, does provide must-have line numbering and is
one of the easiest editors to use. I still prefer vim, but the DOS version of it is really lame, and I don't intend to
teach vi editing in this tutorial.

We'll be writing code specifically to be assembled by [NASM, the Netwide Assembler.](https://www.nasm.us/) There is no
such thing as “standard assembler syntax,” so every assembler has its idiosyncrasies. One of the reasons I'm writing
these tutorials is to teach myself NASM: I actually learned on [TASM](https://en.wikipedia.org/wiki/Turbo_Assembler) 
and worked on [MASM](https://en.wikipedia.org/wiki/Microsoft_Macro_Assembler) in the Bronze Age of computing. The
concepts are the same and linguistic differences are often minor, so it's nothing to break a sweat over.

Some of the programs we write will require a linker. I'm using the public domain **warplink** for this, which can be
found in this repository's resources directory as **wl27.zip**. And finally, since most of these utilities are packaged
as .zip files, we'll snag the darling of DOS [BBSs](https://en.wikipedia.org/wiki/Bulletin_board_system) the world
over, [PKZip](https://oldos.org/downloads/msdos/) (the second-finest piece of DOS shareware ever written.)

Install DOSBox and create a folder in your home directory to keep your work in. I called mine DOS. Edit the DOSBox
configuration file by adding a few lines after the `[autoexec]` section at the very end. Mine automatically mounts my
DOS directory as drive C and adds several directories to my path variable, like this:

```
[autoexec]

# Lines in this section will be run at startup.

@echo off
mount c ~/dos
c:
set PATH=%PATH%;C:\NASM;C:\WARPLINK;C:\EDITV;C:\PKZIP;C:\BIN
```

Once you've done this, you can start DOSBox (which should drop you into your C drive) and use the DOS command `md` to
create the directories **NASM**, **WARPLINK**, **EDITV**, **PKZIP**, **BIN**, and **SOURCE**. Run the command `dir` and 
ensure that eight directories exist (this number includes the `.` and the `..` directories.)

Copy **pk250dos.exe** to the **DOS/PKZIP** directory and run the executable inside DOSBox. You will find that when you 
modify the DOS file system from your host operating system *outside* DOSBox, those changes don't appear when you list 
the directory *inside* DOSBox. DOS likes to cache the directory lists to speed things along, so if it is unaware of 
changes you made from outside the environment, it pretends that they aren't there (they really are.) To force the 
changes to appear, you can clear the directory cache with the `rescan` command.

Copy the rest of the programs listed above to their respective directories and, in DOS, run `rescan` and unzip each of
them like this example:

```
C:\EDITV>pkunzip editv41u.zip
```

When all this is done, close and reopen DOSBox (you can type `exit` at the DOS prompt to close) and verify that you can
run all these programs from the root directory of drive C by just typing their names: `editv`, `nasm`, and `warplink`. 
If you run into any DOSBox trouble, refer to 
[this little article.](https://devtidbits.com/2008/02/17/dosbox-beginners-newbie-and-first-timers-guide/) If 
everything works as expected, your path is set up correctly, your team is assembled, and you're… almost… ready to 
begin…
