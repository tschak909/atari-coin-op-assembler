# atari-coin-op-assembler

This repository contains:

* centipede/ A copy of the Centipede source code from the HistoricalSource repo.
* atari_tools/ The Atari coin-op tools for a PDP-11 system running RT-11
* coin-op/ disk images, and a SIMH configuration file to boot and run the tools

I have placed the read-me for each piece inside each directory.

## centipede

This is the source code to the 1980 coin-op game Centipede, written by DONA BAILEY/ED LOGG. 

It is written to be assembled with the MAC65 macro-assembler, and can be assembled in RT-11 by doing:

```
ASS RK1 OBJ
ASS RK2 BIN

R MAC65
OBJ:CENTI=CENTI
OBJ:CENIRQ=CENIRQ
OBJ:CENTST=CENTST
OBJ:CENPIC=CENPIC
^C

R LINKM
BIN:CENTI,CENTI.XX=OBJ:CENTI,CENIRQ,CENTST
BIN:CENPIC,CENPIC.XX=OBJ:CENPIC
```

(^C means to emit an ASCII 0x03 aka control-C aka ASCII ETX, which is an abort character in RT-11)

This will produce two absolute memory images 

* CENTI.SAV - the main code
* CENPIC.SAV - the picture data

