---
layout: post
title: "Dormant Shell Patch for SMB3"
date: 2020-07-17 12:00:00
description: >
  This patch replaces the hopping green koopa troopa with a shell that never wakes up.
image: /images/patches/dormant-shell-title.png
categories: smb3-patches
---

## Dormant Shell

The hopping green koopa troopa is referenced in the disassembly as `OBJ_PARATROOPAGREENHOP`.
These are recognizable from the middle of Level 1-1 where they are hopping down the colored blocks toward Mario.

![Green Hopping Paratroopa]({{ site.baseurl }}/images/patches/paratroopa-greenhop.gif)

*Green Hopping Paratroopa*
{:.figure}

After using this patch, this enemy spawns already in "shelled" form, and it will never wake up.

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
