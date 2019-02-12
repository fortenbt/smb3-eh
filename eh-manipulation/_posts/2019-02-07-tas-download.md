---
layout: post
title: "Download Early Hammer Manipulation TAS and Lua Helper"
date: 2019-02-07 12:00:00
description: >
  Releases of multiple versions of the Early Hammer manipulation TAS
  and the Lua helper script.
image: /images/tas-download.png
categories: eh-manipulation
---

This is the official first release of the Early Hammer Manipulation TASes and
Lua helper scripts!

### About the TAS and Lua Script

The TAS comes in the format of a `.fm2` file, which is an FCEUX movie file. It
is a plaintext file format that saves the controller inputs for specific frames
that FCEUX plays back while emulating the game cartridge. It is recommended that
FCEUX version 2.2.3 be used to run the TAS and the Lua scripts.

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
