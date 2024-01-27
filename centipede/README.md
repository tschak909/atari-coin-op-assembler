# centipede

In here, is the coin-op code originally pulled from:
https://github.com/historicalsource/centipede

The root contains revision 1 of centipede, which corresponds to MAME's 'centiped1' driver.

The revision.v2/ folder contains revision 2, corresponding to MAME's 'centiped2' driver.

The revision.v3/ folder contains revision 3, corresponding to MAME's 'centiped3' driver.

Revisions 3 and 4 use the CENPIC, and SYNC code from revision.v2, and can be copied over as part of the build process.

Each revision has a set of ROMs built which run in MAME.

For each, there is also a .COM file, containing the build script, as well as .DOC containing testing documentation.

The main CENTI.DOC contains build information, as well as ROM and EPROM mapping, which is important to read if you're trying to either burn new EPROMs or use the ROMs with MAME.

