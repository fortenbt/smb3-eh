---
layout: post
title: "Early Hammer Manipulation TAS Creation"
date: 2019-02-04 12:00:00
description: >
  Description of the TAS creation process for Early Hammer Manipulation
image: /images/tas-creation.png
categories: eh-manipulation
---

This post describes the process of taking the information about known good frames
and producing a tool-assisted speedrun from it that achieves a no-death early
hammer.

### Good Frame Windows

Running [my `smb3rngchk` program](https://github.com/fortenbt/smb3-eh/blob/master/src/smb3rngchk.c)
causes a bunch of information to spit out showing on which end-of-level frames
(see [When Does a Level End]({{ site.baseurl }}/eh-manipulation/2019-01-25-end-level-card/)
for when a level ends) the desired hammer brother movements occur for each level.
This information is summarized at the top of the output by the following lines:

```
Max window for 2-1__1: 5
Max window for 2-2__1: 6
adding window of length 2 for level Level 2-f__1: 12256
adding window of length 2 for level Level 2-f__1: 23081
Max window for 2-f__1: 2
```

Without getting too deep into the weeds about what all of that means, it shows
that the program found one or multiple windows of consecutive frames for
specific hammer brother movements to occur at the end of 2-1, 2-2, and 2-fort.
In the example above, the max amount of frames in a row that it found to give
the desired hammer brother movement after 2-1 was 5. It found a window of 5
frames in a row where the Music Box brother and the Hammer brother moved
to the correct positions. For 2-2, it found a window of 6 frames in a row. For
2-fort, it found a window of 2 frames.

In actuality, the windows my program looks for after 2-fort are not consecutive,
because there's only one window of 2 consecutive frames in a row where our
desired movement occurs, but it occurs too early in [the RNG cycle]({{ site.baseurl }}/smb3mechanics/2018-11-05-no-hands/)
to be used in our TAS. Therefore, our best possible option for a window of frames
is one where our desired movement occurs on one frame, does not on the next, and
then does again on the third: a [good, bad, good] window. There ends up being
two of these such windows, as shown in the program output at frame number 12,256
and 23,081.

Frame number 12,256 occurs roughly 4 minutes (slightly longer than you may
have calculated due to lag frames) after reset, which is not long enough to get to
World 2 and complete 2-fort. Therefore, the only option is to use frame 23,081,
which occurs roughly 6 and a half minutes after reset, right about when we need it.

In order to end 2-fort on this frame, the TAS was made and the frame on which
Mario jumps to grab the orb after killing the boom boom was changed a frame at
a time until we got the lag frame on the correct frame. Then it was verified that
ending the level on this frame did indeed give us the movement we had calculated
that it would. After acheiving the 2-fort movement, the frame window for 2-2 was
searched for.

![Modifying the 2-fort jump a frame at a time]({{ site.baseurl }}/images/create-tas.gif)
*Creating the TAS involves modifying the jump frame a few frames at a time until
the correct end-of-level frame is achieved after hitting the end card or orb.*
{:.figure}

Knowing we'll use frame 23,081 after reset for 2-fort allows us to begin working
backward to figure out which frame window to use for 2-2. Although the program
output shows that there are four 6-frame windows for 2-2 and that there are eight
5-frame windows for 2-2, none of these windows occur close to and before 2-fort's
frame window at 23,081. This is problematic, because if we choose a frame window
that is too many frames before 2-fort's frame window, we have to waste a lot of
time between finishing 2-2 and starting 2-fort, making the whole manipulation
pointless. So the problem becomes finding the best frame window for 2-2 that
occurs fairly close to exactly when we would need it, which is about the time
it takes to move from 2-2 to 2-fort and play through 2-fort, which ends up being
about 2,700 frames. We're looking for 2-2 frame windows around 20,381.

Looking through the program output for 2-2 successes around the frame we needed,
I found a 4-frame window at 20,206:

```
                (Iteration 19522):
                [35 e3 88 4f 5f c1 7e fc 01]
                    Checking 2-2
                        MUSIC BOX: chose LEFT
                        HAMMER: chose UP
                        MUSIC BOX: chose RIGHT
                        Level 2-2__1 SUCCESS ON end of level FRAME 20206

                (Iteration 19523):
                [9a f1 c4 27 af e0 bf 7e 00]
                    Checking 2-2
                        MUSIC BOX: chose LEFT
                        HAMMER: chose UP
                        MUSIC BOX: chose RIGHT
                        Level 2-2__1 SUCCESS ON end of level FRAME 20207

                (Iteration 19524):
                [cd 78 e2 13 d7 f0 5f bf 00]
                    Checking 2-2
                        MUSIC BOX: chose LEFT
                        HAMMER: chose UP
                        MUSIC BOX: chose RIGHT
                        Level 2-2__1 SUCCESS ON end of level FRAME 20208

                (Iteration 19525):
                [66 bc 71 09 eb f8 2f df 80]
                    Checking 2-2
                        MUSIC BOX: chose LEFT
                        HAMMER: chose UP
                        MUSIC BOX: chose RIGHT
                        Level 2-2__1 SUCCESS ON end of level FRAME 20209
```

This frame window ends up being around 3 seconds "too early." That is, we have
to wait around for about 3 seconds somewhere. In the TAS, most of this wait was
placed in 2-fort after killing the boom-boom before jumping to grab the orb.
There is also a 3-frame window at 20,438, which is almost perfect with almost
no lost time waiting around. But using the 4-frame window here also allows us to
hit a better frame window after 2-1. These types of games can be played to get a
TAS that loses less time but sacrifices a better frame window, depending upon
what the desired end result is.

Using the same technique that we used for 2-2, the results of the program were
searched through for 2-1 successes. The best option without sacrificing much
time was found to be a window of 4 out of 6 frames. That is, a [good, bad, good,
bad, good, good] frame window:

```
                (Iteration 17609):
                [c2 fb 7e 88 75 65 8f 44 5a]
                    Checking 2-1
                        MUSIC BOX: chose RIGHT
                        HAMMER: chose UP
                        MUSIC BOX: chose UP
                        Level 2-1__1 SUCCESS ON end of level FRAME 18208

                (Iteration 17610):
                [61 7d bf 44 3a b2 c7 a2 2d]
                    Checking 2-1
                        MUSIC BOX: chose RIGHT
                        HAMMER: chose DOWN

                (Iteration 17611):
                [30 be df a2 1d 59 63 d1 16]
                    Checking 2-1
                        MUSIC BOX: chose RIGHT
                        HAMMER: chose UP
                        MUSIC BOX: chose UP
                        Level 2-1__1 SUCCESS ON end of level FRAME 18210

                (Iteration 17612):
                [98 5f 6f d1 0e ac b1 e8 8b]
                    Checking 2-1
                        MUSIC BOX: chose LEFT

                (Iteration 17613):
                [cc 2f b7 e8 87 56 58 f4 45]
                    Checking 2-1
                        MUSIC BOX: chose RIGHT
                        HAMMER: chose UP
                        MUSIC BOX: chose UP
                        Level 2-1__1 SUCCESS ON end of level FRAME 18212

                (Iteration 17614):
                [e6 17 db f4 43 ab 2c 7a 22]
                    Checking 2-1
                        MUSIC BOX: chose RIGHT
                        HAMMER: chose UP
                        MUSIC BOX: chose UP
                        Level 2-1__1 SUCCESS ON end of level FRAME 18213
```

In order to give the player the best possible chance of jumping on the correct
frame, the TAS was made to hit the 2-frame window within the 4/6 window.

### Lua Helper Script

Early on in the process of developing the early hammer manipulation TASes, Mitch
was having trouble trying to find a visual cue to show him on which frame to
press A to hit the end-of-level card. Initially, I had created the TAS to have
Mario jump three times before hitting the card.
