-----------------------------------------
About
-----------------------------------------

No Overworld by Brolencho, modernized by AmperSam

Originally inspired by "noow.asm" by Alcaro, and does pretty much the same: disables
returning to Overworld after beating levels and instead has the player go through
levels in a sequence, either in numerical order or in an order defined by you.

There is one hijack to fix an issue with No Yoshi entrances.

See "info for coders.txt" for more detailed information.

-----------------------------------------
Installing
-----------------------------------------

Copy all four "no_overworld_*.asm" files into your 'gamemode' folder of UberASM Tool
and add the following to your list.txt file.

    0C no_overworld_gm0C.asm
    10 no_overworld_gm10.asm
    14 no_overworld_gm14.asm

Next, configure the options to your liking in "no_overworld_defs.asm" and run UberASM Tool
to insert.


-----------------------------------------
Uninstalling
-----------------------------------------

This resource needs some extra steps to remove it as it applies a hijack when inserted.

To uninstall, open the "no_overworld_defs.asm" file set !completely_remove to 1 and
run Uberasm Tool. After that, you can delete the no_overworld_*.asm files from your
'gamemode' folder and remove references to them from your list.txt file. Then re-run UberASM Tool
to remove from your project.


-----------------------------------------
Changelog
-----------------------------------------

v1.3 (by AmperSam)
- made compatible with UberASM Tool 2.0
- dropped the 'global_code' instructions in favour of gamemode
- generally made the options and instructions more understandable and readable

v1.2
- Fixed crash with retry patch
- Fixed graphic issue when using "VWF intro 1.22"
- Fixed Player 2 compatiblity with "Exit Block (no OW events)" and "Door exit"
- More info for coders.txt

Thanks to Darolac for pointing some of these issues and testing.

v1.1
- Supports two players
- Secret exits(advanced mode)
- various fixes
- clean.asm is now integrated in NoOverworld.asm