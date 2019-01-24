---
layout: post
title: "Early Hammer Manipulation Summary"
date: 2018-12-14 12:00:00
description: >
  A high level summary and history of the Early Hammer Manipulation strategy
image: /images/eh-manip-summary.png
categories: eh-manipulation
---

This post will provide the backstory behind the Early Hammer Manipulation strats
and how the technique was developed, will give an overview of how it works and
all the parts of the game involved, and introduce the high level technical
details that make it possible.

For any of you who have seen Summoning Salt’s Super Mario Bros. 3 Warpless [World
Record progression video](https://www.youtube.com/watch?v=Ktr9dYUumAs), you’ve
had an introduction to the newest tech trying to push Mario 3 Warpless runs to
the very limit. Dubbed “Early Hammer Manipulation,” this technique attempts to
use knowledge of exactly how the game determines which direction the hammer
brothers in World 2 move at the end of each level combined with near
frame-perfect input to achieve a No-Death Early Hammer (NDEH), saving close to a
minute compared to a run without Early Hammer.

### Background

The story behind Early Hammer manipulation really begins a few years ago around
2015\. When MitchFlowerPower and Kirua were trading the warpless world record back
and forth, they were looking into ways of cutting time off their runs. One of
these ways was to get Early Hammer. At the time, they already knew that which way
the Hammer Brothers moved was based on which frame you ended a level. The tool
assisted speedrun, or TAS, community had already learned they could change the
direction the hammer brothers moved after each level by delaying one frame at a
time until the hammer brother moved the direction they wanted.

The speedrunning community also knew that the random number generator in Mario 3
was deterministic. Every time you reset the Nintendo, Mario 3’s random number
generator spit out the same random numbers each frame. If you recorded one play’s
inputs and played them back on the next run so that the inputs occurred on the
same frames, nothing would change. This is actually how recording a “movie” file
on an emulator works: it simply records the inputs and plays them back on the
same frames. However, if you played the same inputs back starting on only a single
frame later, the game would quickly become desynched from the input. The random
numbers chosen on the first run would be different now that things are happening a
frame later, and thus different decisions would be made by the game code. You can
see an example of this here.

<p>
<iframe src="{{ site.baseurl }}/images/1-3-bro-diff_1.mp4" width="560" height="224"></iframe>
</p>
*Starting the level a single frame later made boomerang bro move forward instead of backward, thus throwing off our recorded input. Mario now gets hit instead of jumping and stomping the boomerang bro.*
{:.figure}

Although the speedrunning community knew that the random number generator was
deterministic, they assumed that if you wanted to control the random values that
determined hammer brother movements in world 2, you would have to play
frame-perfect on every level and on the overworld for world 1 all the way until you
got the hammer brother movements after each of 2-1, 2-2, and 2-fort. Obviously,
playing frame-perfect for so many frames is simply impossible, and they quickly
dismissed the idea and moved on to other strategies.

![Kirua-Tompa discussion]({{ site.baseurl }}/images/kirua-tompa-1.png)
*Kirua and Tompa discussing the Early Hammer Manipulation possibility*
{:.figure}

### Warpless World Record

In June of 2017, Kirua set the warpless world record with a time of 50:57. Earlier
that year in March, MitchFlowerPower [explained that he would be grinding for early
hammer until he got the world record](https://www.youtube.com/watch?v=76G59v7SQDc).
A year later, he finally [got that world record, along with an early hammer and no
hands](https://www.speedrun.com/smb3/run/zpqv29ry) with a time of 50:55.

I had started watching Mitch about a week before he set that record. I was new to the
Mario 3 speedrunning community and was mostly interested in learning exactly why all
the certain strategies and techniques and clips and glitches worked. One of the things
I heard Mitch say during some of his runs was that he hoped someone would make it
their life’s goal to bypass the Hand RNG. That is, find a way to get no hands on every
run. You see, the hand levels occur in World 8, about 45 minutes into the run. To have
so many runs killed 45 minutes in by bad luck was excruciating. I decided this would
be the first thing I looked into to learn exactly how it worked and how it could be
bypassed.

Most of everything I heard about the hands was that they were completely random, with
a 50% chance of getting pulled in. There was no way to avoid them. Everyone had just
accepted that at this point.

### Research

I started doing research into what caused the player to get pulled into a hand level.
Searching through the disassembly, I quickly came across what i was looking for:

```asm
  LDA <World_Map_Move,X
  AND #31                    ; Check if any move is left (relies on starting value of 32!)
  BNE WorldMap_UpdateAndDraw ; If so, jump to WorldMap_UpdateAndDraw...

  ; The move has completed...
  JSR Map_GetTile
  CMP #TILE_HANDTRAP
  BNE WorldMap_UpdateAndDraw ; If the Player has not landed on a hand trap, jump to WorldMap_UpdateAndDraw

  ; Player's on a hand trap...
  LDX Player_Current
  LDA RandomN,X
  AND #$01                   ; 50/50 chance
  BNE WorldMap_UpdateAndDraw ; Player has 50/50 chance we just jump to WorldMap_UpdateAndDraw
                             ;  (50% to (or not to) get pulled into a hand level)
  INC Map_Operation          ; Otherwise, Map_Operation++ (now $E)
  JMP PRG010_CEAC            ; Jump to PRG010_CEAC

WorldMap_UpdateAndDraw:
```
*Listing 1: The overworld movement code where landing tile type is checked*
{:.figure}

This code is run during the player’s overworld map movement on every frame. When a
single movement is completed (e.g. when Mario lands on a tile), the tile type is
checked to see if it is a hand trap tile. If it is, a number is grabbed from an
array of random numbers, and its least significant bit is checked. If the bit is a
one, or the number was odd, the player is safe. If the bit was a zero, or the number
was even, the current `Map_Operation` is changed to the value `0xE` (14), which is
`MO_HandTrap` (Map Operation HandTrap), and the player gets pulled down into the
level.

Alright, we got somewhere. It looked like everything boiled down to which byte was
grabbed from the `RandomN` array in the code. The next step was to look into that. I
completed a lot of research and published my [Look Ma, No Hands!]({{ site.baseurl}}/smb3mechanics/2018-11-05-no-hands/)
article detailing possible RNG manipulation strategies to avoid the hand levels. The
basic conclusion was that, due to lag frames and how long it took to get to the hands,
manipulating RNG to avoid the hand levels for the Warpless category was not feasible.

### MitchFlowerPower's Early Hammer Manipulation

Right as I was finishing the No Hands article, I was still watching Mitch speedrun
Super Mario Bros. 3. He had switched back to attempting Warpless at this point, and he
had a new strategy, something he called Early Hammer Manipulation. He created a TAS
that got a large hammer brother movement in World 2 where the Music Box bro and the
Hammer bro switched positions after a quick death in 2-fort. His strategy to get the
right movements was to play while watching the TAS, synchronizing the start of his TAS
with powering on his NES, and then playing through to World 2 and trying to get the
same hammer brother movements. He would stop and wait at the end of level 2-1 and level
2-2 and then jump at the same time as the TAS so that he hopefully hit the end level
card on the same frame. He then showed a strategy to get a consistent death in 2-fort
that would cause the Hammer bro to move down and left to end up just to the right of
2-3.

When I saw what he was doing, I was immediately excited. Finally, a method I could
actually use to exploit the random number generation! I knew that what he was doing
was slightly flawed, due to the lag frames he wasn’t taking into account. And there was
still a ton of work to be done to find the largest windows of good frames to jump at
the end of each level. I got in touch with him to let him know that I was working on
finding the best windows of frames at the end of each of level 2-1, 2-2, and 2-f, and
that I could also make a TAS to go for a no-death early hammer. I thought it wouldn’t
take that long to run my program and figure out which frames gave which movements.
Boy, was I wrong.

### Proving The Naysayers Wrong ;)

![Naysayers :FireFlowerMarioLookingOutHisWind:]({{ site.baseurl }}/images/naysayers.png)

The next couple months involved a lot of reverse engineering and studying the SMB3
disassembly to understand the ins and outs of the Hammer Brother movement mechanics
and other SMB3 internals that affected when those movement decisions were made.

I looked into how the end-level card is spawned and how it and the in-game timer may
affect the frame on which the level ends.

I wrote a lot of [code](https://github.com/fortenbt/smb3-eh/blob/eh-manip/src/smb3rngchk.c)
that simulated the random number generator and the hammer brother movement decision
code in order to find the best possible windows of frames to jump to hit the cards
and the orb at the end of 2-1, 2-2, and 2-fort.

I worked with Mitch to create multiple TASes to hit the best windows while keeping
it as followable as possible for an RTA runner.

I wrote multiple LUA scripts for the emulator playing back the TAS to give a
frame-perfect visual cue to assist in timing the end-of-level jumps.

In the end, Mitch was able to use the Early Hammer Manipulation strategy to get a
No-Death Early Hammer, continue the run through to the hands, get pulled into one
hand, and still complete the run with a time more than 19 seconds faster than his
previous world record run that contained a 1-death early hammer and no hands. That
run can be seen [here](https://www.speedrun.com/smb3/run/zp06548m).

The description of the hammer brother movement mechanics was already posted in my
[Early Hammer post]({{ site.baseurl }}/smb3mechanics/2018-08-22-early-hammer/), and
the next few posts in this category will go in depth into the rest of the research
behind the Early Hammer Manipulation strategy development. I'll also be releasing a
set of TASes and LUA helper scripts that will be tailored for multiple skill levels
so that many runners can attempt early hammer manipulation for the Warpless category.
