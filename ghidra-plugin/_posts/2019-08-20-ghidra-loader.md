---
layout: post
title: "Ghidra Loader for Super Mario Bros. 3 NES ROM"
date: 2019-08-20 12:00:00
description: >
  A loader specifically for loading the PRG1 version of
  the Super Mario Bros. 3 NES ROM with all the symbols
  from Captain Southbird's full disassembly.
image: ghidra-bros-3.png
categories: ghidra-plugin
---

I've completed a Ghidra loader that correctly maps in all the ROM's program banks
at their respective addresses along with all of the symbols from the complete
disassembly located [on GitHub](https://github.com/captainsouthbird/smb3).

### Super Mario Bros. 3 NES ROM Versions

There were two versions of the Super Mario Bros. 3 US region cartridge: Rev 0
and Rev 1. Their respective ROM files are suffixed `(U) (PRG0) [!]` and `(U) (PRG1) [!]`.
The only major visual difference between the two are the names of the Worlds as shown
during the end credits after beating the game. The different names are shown in the table
below ^1.

| **US (Revision 0)** | **US (Revision 1)** |
|:-------------------:|:-------------------:|
|Grass Land | Grass Land |
|Desert Hill | Desert Land |
|Ocean Side | Water Land |
|Big Island | Giant Land |
|The Sky | Sky Land |
|Iced Land | Ice Land |
|Pipe Maze | Pipe Land |
|Castle of Koopa | Dark Land |

Other than that, there's some minor differences in the location of some routines in bank 31.

Captain Southbird's disassembly assembles byte-for-byte into the PRG1 version of the
ROM, and therefore the symbols and their addresses in the loader are matched to that
ROM.

### MMC3 Mapper and Banking

The total size of the Super Mario Bros. 3 NES ROM is 393,232 bytes. There is a 16-byte INES
header followed by the actual cartridge contents. The cartridge contents are broken up into
the PRG ROM (program memory) consisting of 32 banks of 8,192-byte blocks of 6502 code and
the CHR ROM (character memory) consisting of 128 blocks of 1,024-byte graphics data.

However, the 6502 processor only supports 16-bit addressing and was only designed to address
32 KB of PRG ROM in the 32 KB of address space from `0x8000` through `0xFFFF`. RAM and other
peripherals are mapped at lower memory addresses. In order to fit the entire game's code in
32 KB, the MMC3 mapper hardware was used within the cartridge. This extra hardware allowed
the process of banking to occur, where running code could write to special registers on the
cartridge to swap in and out specific banks of the PRG code when it needed them.

In Super Mario Bros. 3, banks 30 and 31 are always present at addresses `0x8000-0x9FFF` and
`0xE000-0xFFFF`, respectively. All the other banks are written to exist at either `0xA000-0xBFFF`
or `0xC000-0xDFFF`. This can easily be seen in Southbird's complete disassembly in the main
[`smb3.asm` file](https://github.com/captainsouthbird/smb3/blob/master/smb3.asm#L4653), which
uses the `.include` and `.org` macros to include the PRG bank files assembled at specific base
addresses.

### Ghidra Memory Blocks

When beginning to write the Ghidra Loader, I was completely new to their API and really had no
idea how I was meant to go about loading in each bank. I referenced multiple open source loaders
for different formats to begin to find my way around. A few of these are listed below:

- [Nintendo Switch Loader](https://github.com/Adubbz/Ghidra-Switch-Loader)
- [XBOX Executable (xbe) Loader](https://github.com/jonas-schievink/GhidraXBE)
- [Mobicore Trustlet Loader](https://github.com/NeatMonster/mclf-ghidra-loader)

One of the things I noticed was that none of the open source projects I found really did anything
similar to loading multiple code blocks at the same virtual address, something that was required
for the MMC3 banking construct. Turning to [Ghidra's documentation](https://ghidra.re/ghidra_docs/api/index.html),
I found that it was really lacking for someone coming into the API completely new and looking to
find an overview of the model or examples of how one might do different things.

After clicking through much of their object model, trying to keep it all straight in my head
(it's still confusing that you seem to be able to do the same thing from multiple different
places within the object hierarchy), and after playing around with the memory space window in
the GUI, it seemed like the best option would be to create a `MemoryBlock` for each bank, each
one backed by the corresponding file contents of that bank.

I immediately got an error during loading saying that I had overlapping memory blocks:

```
Failed to add language defined memory block due to conflict: STACK @ 0x0100, length=0x1ff
```

Wait a minute, though...that's a language-defined memory block called `STACK` at address
`0x0100`. I didn't attempt to define that with my loader. Grepping through their source,
I found some memory blocks defined in a file within a `language` directory called `6502.pspec`.
This processor spec file defined multiple blocks of memory by default for any 6502 binary
loaded into Ghidra. This was broken by default!

The default memory blocks defined were:

```xml
  <default_memory_blocks>
    <memory_block name="IO" start_address="0" length="0x20" initialized="false"/>
    <memory_block name="LOW_RAM" start_address="0x20" length="0xff" initialized="false"/>
    <memory_block name="STACK" start_address="0x0100" length="0x01ff" initialized="false"/>
  </default_memory_blocks>
```

There was an "IO" block from `0x0` through `0x20`, "LOW_RAM" from `0x20` through...`0x1DF`?
That had to be wrong. In the 6502 architecture, addresses `0x0` through `0xFF` are called
the "zero page", because those addresses can be accessed with a single byte (the high
address byte is zero). This would make sense to define a default memory block from `0x0` through
`0xFF` called `LOW_RAM`, but this block started at `0x20` and its length was `0xFF`.
Even if the starting address was `0x0`, the length of `0xFF` would set the memory block
to addresses `0x0` through `0xFE`. Something was obviously overlooked.

I guessed that there used to be a "LOW_RAM" block defined from `0x0` through `0xFF`, and that
the `pspec` format used to specify `start_address` and `end_address`. At some point, there
was a system with a 6502 processor that someone at the NSA was reverse engineering that had
IO at addresses `0x0` through `0x20`, so they modified the `pspec` file to support this.

Eventually, the `pspec` file format was reworked and modified to take a `length` parameter,
and loading a 6502 file never really got any attention. I went ahead and [created an Issue
and Pull Request in the Ghidra codebase](https://github.com/NationalSecurityAgency/ghidra/issues/864),
and it was recently merged.

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

![Finding About]({{ site.baseurl }}/images/fceux-about.png)
*The version of FCEUX can be found in its About menu.*
{:.figure}

![FCEUX version]({{ site.baseurl }}/images/fceux-about-box.png)
*FCEUX version 2.2.3*
{:.figure}

The TAS was made for the PRG0 version of the Super Mario Bros. 3 ROM. Although
there are very few substantive changes between the two ROMs, they have been
known to desynch from the TAS if the wrong ROM is used.

The Lua script is a script that was written for FCEUX's Lua API. It draws
transparent boxes across the top of the screen that fill in once the jump frame is
getting close. By default, the script draws 9 boxes and waits 45 frame between each
box filling in. These values, as well as the size of the boxes are easily changed
by modifying the values at the top of the script to allow a speedrunner to customize
it to their liking:

```lua
-- Allows you to adjust how many frames between each box being filled in
local countdown_delay = 45

local goodframe_2_1 = 17821 -- 688 lag, 289 ingame clock, 18212 end of level lag frame
local goodframe_2_2 = 19725 -- 773 lag, 285 ingame clock, 20207 end of level lag frame
local goodframe_2_f = 22672 -- 872 lag, 277 ingame clock, 23079 end of level lag frame

local screen_width  = 0x10 --256 pixels, 16 blocks
local screen_height = 0x0F --240 pixels, 15 blocks

-- Allows you to adjust how many boxes to display on screen
local nboxes = 9

-- Allows you to adjust how big the boxes are
local box_size = 20
local space_size = 5
local box_y = 20
```
*Listing 1: The Lua script configuration variables*
{:.figure}

### Loading the TAS

The TAS can be loaded using FCEUX's `File...Movie...Play Movie` menu. You can click
the dropdown, click `Browse`, and then navigate to where you downloaded the TAS.

![Play Movie]({{ site.baseurl }}/images/play-movie.png)
*FCEUX's Play Movie menu*
{:.figure}

![Loading the TAS]({{ site.baseurl }}/images/browse-fm2.png)
*Loading the No-Death Early Hammer TAS*
{:.figure}

### Loading the Lua Script

Once the TAS is loaded, you can load the Lua script by going to
`File...Lua...New Lua Script Window...`. On the window that comes up, click `Browse`,
and navigate to where you downloaded the Lua script, select it, and click `Open`.
Finally, click `Run`. Make sure you are running the correct Lua script for version of
the TAS you are running so that the boxes match up with the frames on which to jump
to get the correct hammer brother movements.

![New lua script]({{ site.baseurl }}/images/new-lua-script.png)
*FCEUX's new lua script menu*
{:.figure}

![Load lua]({{ site.baseurl }}/images/load-lua.png)
*Browsing to the Early Hammer helper Lua script*
{:.figure}

![Run lua]({{ site.baseurl }}/images/run-lua.png)
*Click Run to start the Lua script*
{:.figure}

### The Two Current TASes

The two TASes and Lua scripts I am releasing right now are versions `v0.4` and `v0.5`.
I am not numbering them `v1.0` yet, as I am still not satisfied that they're as good
as they can be.

Because of github- and my jekyll theme-related issues, I haven't been able to get the
links below to download the files. You can right click the orange arrow next to the
images and choose "Save link as..." in order to save the files.

![Save link as]({{ site.baseurl }}/images/right-click.png)
*Right click and Save link as...*
{:.figure}

#### v0.4

`v0.4` is the version of the TAS that [Mitchflowerpower](https://twitch.tv/mitchflowerpower)
used to achieve the [current world record for Warpless](https://www.twitch.tv/videos/365679017)
in January 2019 with a 50:36.

The frame windows achieved in this TAS are shown below. The frames marked with an asterisk (`*`)
are the frames on which the TAS jumps. A frame labeled `good` is one where the hammer brothers
move as-desired if you press jump to get the card on that frame. A frame marked `bad` is one
where the hammer brothers move incorrectly.

```
2-1: [good, bad, good*, good]
2-2: [good, good*, good]
2-f: [good*, bad, good]
```

<a href="https://raw.githubusercontent.com/fortenbt/smb3-eh/master/tas/v0.4/orange-nodeath-eh-v0.4.fm2" download>
    <img src="{{ site.baseurl }}/images/flower-card.png" width="128" height="128">
</a>
*v0.4 TAS*
{:.figure}

<a href="https://raw.githubusercontent.com/fortenbt/smb3-eh/master/tas/v0.4/eh-helper-v0.4.lua" download>
    <img src="{{ site.baseurl }}/images/lua-logo.png" width="128" height="128">
</a>
*v0.4 Lua script*
{:.figure}

#### v0.5

`v0.5` removes the delag strategies in 1-1 and assumes a 4-frame lag. It does this to make
up some time lost in World 2 in order to get longer frame windows. It is overall about 4
seconds slower than `v0.4`.

```
2-1: [good, bad, good, bad, good*, good]
2-2: [good, good*, good, good]
2-f: [good*, bad, good]
```

<a href="https://raw.githubusercontent.com/fortenbt/smb3-eh/master/tas/v0.5/orange-nodeath-eh-v0.5.fm2" download>
    <img src="{{ site.baseurl }}/images/flower-card.png" width="128" height="128">
</a>
*v0.5 TAS*
{:.figure}
<a href="https://raw.githubusercontent.com/fortenbt/smb3-eh/master/tas/v0.5/eh-helper-v0.5.lua" download>
    <img src="{{ site.baseurl }}/images/lua-logo.png" width="128" height="128">
</a>
*v0.5 Lua script*
{:.figure}

### Using the TASes

In order to use the TAS successfully, you must do a couple things:

First, your NES or emulator must be started at the exact same time as the emulator that is
playing the TAS. If these are desynched at all, you'll be a frame or more off, giving you
less of a chance of getting the manipulation.

Second, it is not crucial for your gameplay to try to emulate the TAS's outside of delag
strats. Obviously, you'll want to use the same delag strats as the TAS uses, but any other
strategies to get ahead of the TAS are completely fine. However, this is only applicable
up to World 2. When you start World 2, you need to try to enter 2-1 at the same time as
the TAS. Due to the [in-game timer effects]({{ site.baseurl}}/eh-manipulation/2019-01-25-end-level-card/),
you need to hit the card at the end of the level with the same in-game timer that the TAS
does. The easiest way to achieve this is to attempt to enter the level at the same time.

Mitch [posted a good tutorial on Early Hammer Manipulation](https://www.youtube.com/watch?v=2syj3j0Ye_E).
