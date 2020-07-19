---
layout: post
title: "Dormant Shell Patch for SMB3"
date: 2020-07-17 12:00:00
description: >
  This patch replaces the hopping green koopa troopa with a shell that never wakes up.
image: /images/patches/dormant-shell-title.png
categories: smb3-patches
---

## Dormant Shell Patch

<p align="center">
<a href="https://raw.githubusercontent.com/fortenbt/smb3-eh/master/patches/dormant-shell-v1.0_PRG0_PRG1.ips" download>
    <img src="{{ site.baseurl }}/images/patches/ips-icon.png" width="128" height="128">
</a>
</p>

*[Download] Green Paratroopa to Dormant Shell Patch*
{:.figure}

The hopping green koopa troopa is referenced in the disassembly as `OBJ_PARATROOPAGREENHOP`.
These are recognizable from the middle of Level 1-1 where they are hopping down the colored blocks toward Mario.

![Green Hopping Paratroopa]({{ site.baseurl }}/images/patches/paratroopa-greenhop.gif)

*Green Hopping Paratroopa*
{:.figure}

After using this patch, this enemy spawns already in "shelled" form, and it will never wake up.

## Patch Details

The source diff for this patch can be found on my branch for it [on GitHub](https://github.com/fortenbt/smb3/commits/patches/dormant-shell)

The green hopping paratroopa is implemented in bank 4 (`prg004.asm` in the dissassembly). However, objects in the
shelled state are handled completely by code in one of the fullest banks in the game: bank 0. Due to this,
the code for singling out the green hopping paratroopa to never wake up is implemented in a bank that is always
present in memory. This avoids switching banks within enemy handling code, which is one of the main causes of lag
in the game.

I usually try to avoid putting code in the "always present" banks (`prg030` and `prg031`), but there truly is a lot
of space and this is one of the times I think it's warranted.

To implement this patch, I modified the green paratroopa's initialization routine to be a custom one I fit in
some dead code in bank 4. The custom routine simply sets the object state to shelled rather than normal before
calling the standard initialization routine.

```asm
	; DEAD CODE
	;;LDA #$10
	;;STA <Objects_YVel,X

	;;; [ORANGE] We removed the 4 bytes of dead code above to fit this small Init_Shelled
	;;; The JSR is only 3 bytes, so we have an extra $FF byte here to fill the 4 bytes we removed.
	.byte $FF
ObjInit_ShelledTroop:
	JSR Object_SetShellState		; [ORANGE] This sets A to $FF and so returns zero flag not set
	BNE ObjInit_GroundTroop
```

*Listing 1: Assembly for initializing the green paratroopa*
{:.figure}

This forces the green paratroopa to spawn in shelled state, but it then wakes up 255 frames later.

To handle this, we look at the code handling objects in shelled state in bank 0: the routine named `ObjState_Shelled`.
Within this routine, `Object_ShellDoWakeUp` is called. This routine has some checks for specific objects,
including `OBJ_BOBOMBEXPLODE` and `OBJ_ICEBLOCK`, and we insert a hook after those to check for our
own object. Our hook is placed over top of the code that gets the wakeup timer to see if the object
needs to wake up.

This allows us to check the object first, and then always set to the wakeup timer to be a high value
prior to the game checking if the object needs to wake up.

```asm
	;;; [ORANGE] We can modify the wakeup timer here for specific objects
	;;;LDA Objects_Timer3,X
	JSR GetWakeupTimer
```

*Listing 2: Assembly for disallowing our green paratroopa shell to wake up*
{:.figure}

## Patch Application

This IPS patch can be applied via [Lunar IPS](https://www.romhacking.net/utilities/240/).

It *should* be compatible with every other patch found on this site, but due to the complications involved in
keeping many patches compatible with each other you may run into issues if you apply multiple patches.

The patch can be applied to either the US PRG0 or PRG1 versions of the ROM. Typically, if you have a ROM that isn't
labeled PRG0 or PRG1, it is PRG0. The PRG0 version of the ROM has the "better" world names during the credits
after beating Bowser:

| **US (PRG0)** |	**US (PRG1)** |
| :----: | :----: |
| Grass Land | Grass Land |
| Desert Hill | Desert Land |
| Ocean Side | Water Land |
| Big Island | Giant Land |
| The Sky | Sky Land |
| Iced Land | Ice Land |
| Pipe Maze | Pipe Land |
| Castle of Koopa | Dark Land |