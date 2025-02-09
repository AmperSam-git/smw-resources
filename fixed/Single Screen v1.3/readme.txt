# Single Screen v1.3 by TheBiob

This resource will lock the camera to a single screen and scroll to the next only when
the player reaches the edge or crosses a set threshold. See the ASM file itself for more
information and configuration options.

If there are issues with sprites spawning while moving left, apply the "Sprite Scroll Fix"
patch found here: https://smwc.me/s/13675

NOTE: the default Horizontal Level Mode (00) does not provide enough height for vertical
scrolling to work. Changing the Horizontal Level Mode to 02 or greater will give
enough height to be sufficient.


## Conflicts

This resource has a small hijack that will conflict with the preparation patch in the
"Horizontal/Vertical Level Wrap" resource found here: https://smwc.me/s/18441

To avoid this, open the ASM file and change the "!UseSideExitHijack" to to zero (0) to
omit using the hijack.


## Removing

Since this resource has a small hijack, when removing open the ASM file and change
the "!UseSideExitHijack" to to zero (0) then, re-run UberASM Tool to remove the hijack.

Then remove the resource from your list.txt and re-run UberASM Tool.


## Changelog

V1.1 Changes
- Now works with LM3 level sizes
- Start can optionally be aligned to a screen but isn't required to anymore
- Options to disable horizontal/vertical scrolling separately
- More options to change the size of the screen/when the scrolling triggers
- Removed the "code per screen" feature since I think it doesn't really work with big level sizes*

V1.2 Changes
- Fixed graphics bugging out when pausing the game during a screen transition.
- You can choose between pausing the transition or not allowing to pause during transitions.

V1.3 Changes (by AmperSam)
- reworked FreeRAM to use empty RAM to avoid any issues with other resources.
- made the definitions and options easier to understand.
- changed the default configuration to actually be screen dimensions instead of a square.
- moved the hijack into an if statement.
- applied fix from Kevin for vertical levels.
- included fix from Koopster to accommodate Retry System.
