# atari_tools

These tools were recently (November 2023) uploaded to Bitsavers, and are present here for convenience.
They were originally from here: https://bitsavers.org/bits/Atari/arcade/atari_tools.zip

They consist primarily of dumps of several DEC RX01 format disks

* e2_tools - Containing source code to RT-11 tools, and parts of the macro assemblers
* e3_tools - More tool and operating system source code.
* e4_tools - Even more tool and operating system source code, some bits in Pascal too.
* e5_tools - the last of the source code, including source to runoff.
* e6 - binaries for MAC65, MAC68, MAC69, MACRO, and a few bits of MAC source and a PASLIB pair.
* f8 - other binaries for MAC65, MAC68, these run, but behave slightly differently (why?)

## Transferring into SimH

The paper tape reader and punch are the most straightforward way to transfer files into the filesystem, e.g. to transfer something in:

(^E means hit control-E)

```
^E
sim> att ptr atari_tools/e6/MAC65.SAV
sim> cont
COPY PC: SY:MAC65.SAV
```

The punch can be used to send something out:

```
^E
sim> att ptp centi.sav
sim> cont
COPY BIN:CENTI.SAV PC:
^E
sim> det ptp
```

**det ptp must be used to detach the paper tape punch, so that the file will properly be closed, and readable.**

## Assembly

Looking at the CENTI.COM command file, you'll see the commands needed to assemble and produce the ROM images.

Here is an example MAC65 run:

```
.DIR RK1:
 
CENDEF.MAC    23                 CENIR2.MAC    22           
CENPIC.MAC    24                 CENTI2.MAC   105           
CENTS2.MAC    37                 COIN65.MAC    48           
SYNC2 .MAC     4                 CENTI2.OBJ    14           
CENIR2.OBJ     6                 CENTS2.OBJ     6           
CENPIC.OBJ    11                 
 11 Files, 300 Blocks
 4462 Free blocks

.R MAC65
*OBJ:CENTI2=CENTI2
ERRORS DETECTED: 0
FREE CORE: 14275. WORDS

*OBJ:CENIR2=CENIR2
ERRORS DETECTED: 0
FREE CORE: 12969. WORDS

*OBJ:CENTS2=CENTS2
ERRORS DETECTED: 0
FREE CORE: 15318. WORDS

*OBJ:CENPIC=CENPIC
ERRORS DETECTED: 0
FREE CORE: 16243. WORDS
```

This produces a set of relocatable object files:

```
.DIR DK1:*.OBJ
 
CENTI2.OBJ    14                 CENIR2.OBJ     6           
CENTS2.OBJ     6                 CENPIC.OBJ    11           
 4 Files, 37 Blocks
 4462 Free blocks
```

But we still need to produce an absolute memory image, and we will need the LINKM linker for this, both to resolve the symbols that are split into several files, and to fix up the relative addresses into absolute ones.

```
.ASS RK2 OBJ
.ASS RK2 BIN
.R LINKM
*BIN:CENTI2,CENTI2.XX=OBJ:CENTI2,CENIR2,CENTS2

*BIN:CENPIC,CENPIC.XX=OBJ:CENPIC

^C
.
```

At this point we have two SAV files.

```
.DIR DK2:*.SAV
 
CENPIC.SAV     8                 CENTI2.SAV    33           
 2 Files, 41 Blocks
 4718 Free blocks
```

## IMGFIL

There was a tool called IMGFIL that was present on the coin-op systems. It is not present here. But it can be replicated with other tools. 

This program took as input:

* The BINARY (SAV) file to cut into pieces
* The image size (2048, for 2K ROMs)
* any number of image files
** image file name
** image offset in hex

An example run with CENTI, outputting to 2048 byte files, with offsets at 2000, 2800, 3000, and 3800 hex:

```
R IMGFIL
BIN:CENTI
2048
IMG:136001.103
2000
IMG:136001.104
2800
IMG:136001.105
3000
IMG:136001.106
3800
^C
```
