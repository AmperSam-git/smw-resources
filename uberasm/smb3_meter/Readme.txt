# SMB3 P-Meter UberASM

This is an UberASM conversion and enhancement of Ersanio's "SMB3 P-Meter" patch
to display the p-meter in the status bar.

See the ASM file itself for more configuration options.

## Inserting

If you're using hack-wide insert as level ASM or use in gamemode 13 and 14:

    gamemode:
        13 smb3_pmeter.asm
        14 smb3_pmeter.asm


Replace GFX28 in the Graphics of your project with the modified GFX28.bin 
and re-insert Graphics.

Keep a copy of the original GFX28 if you ever plan to remove this resource.


## Removing

Since this resource has a small hijack, when removing open the ASM file
and change "!UseStatusHiJack" to zero then, re-run UberASM Tool to remove
the hijack.

Then remove the resource from your list.txt and re-run UberASM Tool