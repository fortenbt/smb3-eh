---
layout: post
title: "End Level Effects"
date: 2019-01-25 12:00:00
description: >
  Technical details on the effects the end-of-level card and in-game timer
  countdown has on Early Hammer Manipulation.
image: /images/end-level-card.png
categories: eh-manipulation
---

This post will provide details on the pain and suffering went through to
understand why the in-game timer affects which frame the level ends on as
well as why which card is grabbed in a run can be different than what is
shown in the TAS being followed while still being the correct frame.

### When Does a Level End?

To understand how the in-game timer affects frame on which the level ends,
we must first define what the end of a level is. We could use some definition
like the first frame where the whole screen goes black, or the first frame
where the overworld map is shown. This is slightly problematic, though,
because the level fades out across many frames at the end and then the
overworld fades in across many frames as well. It would be very hard to tell
when the first truly all-black frame occurred or when the first overworld
frame occurred.

When working with FCEUX's TAS Editor, however, there is something that occurs
that makes a very clear distinction as to when the level ends: lag frames.
I had looked into lag frames a lot during the [No Hands research]({{ site.baseurl}}/smb3mechanics/2018-11-05-no-hands/),
and I found that they are colored pink in FCEUX's TAS Editor.

![End of level lag frame]({{ site.baseurl }}/images/eol-lag.gif)
*FCEUX's TAS Editor very clearly shows the first frames of the end of level
transition due to the lag frame.*
{:.figure}

Because of this very clear distinction as to when the level ended and the
transition to the overworld occurred, I began using the frame on which the
first lag frame occurred as my marker for when the level ended.

Exactly when the level ends matters for Early Hammer Manipulation, because
the hammer brothers choose their facing direction and which way they move a
constant number of frames after the end of the level. I detail these decisions
and how they're made in the [Early Hammer post]({{ site.baseurl }}/smb3mechanics/2018-10-01-early-hammer.md/).

### In-Game Timer Effects

While creating the Early Hammer Manipulation TAS that achieves a No-Death
Early Hammer and hits the frame windows at the end of 2-1 and 2-2, I
continuously ran into problems when I would try to change anything. If
the first TAS I made was too perfect within the level or didn't wait long
enough at the end of the level, I would have to modify those things, which
changed the exact frame at which I hit the card at the end of the level.

I would then fix up the frame on which I jumped to hit the card so that it
was the same frame number I had jumped on before the changes, and the hammer
brothers would move differently! It seemed almost random when it would happen,
and I started to be worried that it was based on yet another random element
that we wouldn't be able to control. After much testing, it seemd the in-game
timer had an effect, but I didn't know how it affected it.

At this point, I was desperate, thinking that maybe how long you held A on your
jump to grab the card affected the number of frames to end the level. I
appealed to the discord community, hoping someone knew something. It turns out
Tompa knew exactly what was going on.

![Tompa the SMB3 Internals God]({{ site.baseurl }}/images/tompa-timer.png)

Aha! It was so obvious! The in-game timer counts down to zero to increase a
player's score after hitting the card. For every 10's digit, the game took one
frame to decrement the timer by ten. After decrementing the 100's and the 10's
ten frames at a time, the rest of the 1's digits were decremented one at a time.

If the in-game timer ended in 293, it would take 29 frames to count down the
290, and then 3 more frames to count down the 3, for a total of 34 frames.

![In-game Timer Countdown]({{ site.baseurl }}/images/timer-countdown.gif)

If the changes I made caused the TAS to wait longer under the card at the
end of the level before hitting it and the end-level timer counted down
further, that would change the number of frames between hitting the card
and when the level ended. Even if I jumped on the same exact frame as before,
the different number of frames for the timer countdown would change which
frame the level ended, thus changing which frames the hammer brothers chose
their facing direction and movement.

This meant an RTA runner had to keep the same in-game timer value as the TAS
they were following in order to attempt to end the level on the same frame.
This became a bigger problem in 2-1, because the TAS hit the end-level card
with 290 left on the in-game timer. If a player entered the level earlier
than the TAS in order to stay ahead of it and have as much time as possible
to jump at the same time as the TAS, they would sit under the card longer,
allowing the timer to count down to less than 290. Because of the timer
countdown mechanics, a 289 takes 37 frames to count down, while the 290 takes
29 frames to countdown. That's a difference of 8 frames from just one second
difference on the in-game timer! Because the TAS for 2-1 hit the card at
290, any extra waiting would cause a huge difference in frames. This made it
vital that an RTA runner entered the level at close to the same time as the
TAS so that they ended the level with the same in-game timer.

Entering the level at the same time as the TAS is less crucial in 2-2 and
2-fort due to the end-level in-game timer values being 285 and 277,
respectively. If a player waited slightly longer and got a 284 or 276 in
these levels, it would only be 1 frame difference, which may be counteracted
by a slightly late A-press on the jump frame window.

A big thanks to Tompa for sharing some of his extensive SMB3 knowledge during
this investigation.

### End-Level Card Image

Now that we understood how an RTA runner could consistently follow a TAS
to hit the end-level card on the same frame as the TAS, we started testing
it with real runs. [Mitchflowerpower got the first ever real-time Early
Hammer Manipulation](https://www.twitch.tv/videos/292407688?t=00h05m10s)
and wasn't sure he was getting the correct frames because the end-level
card images he got were different than what the TAS got.

I decided to verify why we couldn't rely on those end-level card images
to know if the frame was correct to make sure we understood everything.

#### End-Level Card Object

The end-level card is one of Super Mario Bros. 3's objects that are tracked
by multiple arrays in memory. The objects' IDs, x-positions, y-positions,
x-speeds,  y-speeds, states, counters, etc. are all stored in arrays
throughout memory. The arrays can track up to 8 objects at one time, and
Most objects are spawned into one of the currently unused locations in the
object arrays when the player scrolls the screen close enough to those
objects. If there are no unused locations for the object to spawn, it
won't, and this is called despawning the object. This is sometimes used
as a strategy to allow for a speedrunner to get past certain locations in
the levels without having to deal with an enemy.

The end-level card is slightly special in that it always spawn in the 6th
slot in the object array. This slot holds special objects and ensures that
those objects will never be able to be despawned. No matter what a player
does, the end-level card will always spawn. Another example of a special
object is the bouncy note block that is spawned when a player lands on the
note block tile in a level.

The following code in the disassembly is responsible for changing the
end-level card between a mushroom card, a flower card, and a star card every
eight frames.

```asm
EndLevelCard_Untouched:
    LDA <Counter_1
    AND #$07
    BNE PRG002_BB65  ; 1:8 ticks continue, otherwise jump to PRG002_BB65

    ; Run through frames 0-2
    INC Objects_Frame,X
    LDA Objects_Frame,X
    CMP #$03
    BLT PRG002_BB65

    ; Restart animation loop
    LDA #$00
    STA Objects_Frame,X

PRG002_BB65:
```
*Listing 1: The code responsible for changing the end-level card every 8
 frames after it is spawned*
{:.figure}

This code runs after the end-level card is spawned and every frame until
the end-level card is touched by the player. The first thing it does is
check the `Counter_1` value and look at the three least significant bits.
If they're all zeros, it increments the `Objects_Frame` variable through
the values 0, 1, and 2 over and over again. 0 is the Mushroom, 1 is the
Flower, and 2 is the Star. When the card is spawned by the player scrolling
the screen far enough, the card is initialized to be the Mushroom. It will
only stay on the Mushroom until the `Counter_1` counter's least significant
three bits are zero—this could be between 0 and 7 frames—before changing
to the Flower card. From then on, the card changes every eight frames,
scrolling through Mushroom, then Flower, then Star, then Mushroom, etc.

The `Counter_1` value is simply incremented on every frame, so it could
be any value on the frame the end-level card is spawned. This means the
first card image could change immediately (0-frame delay) or could take
8 frames to change, depending upon the value of `Counter_1` when it was
spawned.

In the following example video, when the end-level card was
spawned, it only stayed on the mushroom card for two frames before
changing to the flower. After that, the card changes every 8 frames.
Because of this, if a player does not spawn the end-level card on the
exact same frame as the TAS they're following, the end-level card could
differ even if they jump and hit the card on the exact same frame as the
TAS.

<p>
<iframe src="{{ site.baseurl }}/images/end-level-card/end-level-card.mp4" width="777" height="437"></iframe>
</p>
*Example of the first card changing only after 2 frames*
{:.figure}

This finally explained why Mitch successfully achieved the Early Hammer
Manipulation No-Death Early Hammer while getting a different end-level
card than the TAS.
