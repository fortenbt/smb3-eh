# Early Hammer

Early Hammer is the name given to the scenario in World 2 when the Boomerang Brother that holds the hammer moves across the 2-sun level and possibly even 2-3 in order for the player to get a hammer before playing those levels. If the hammer is used on the block below 2-3, up to three levels can be skipped (2-3, 2-sun, and 2-5), saving a speedrunner roughly a minute.

The Boomerang Brothers in  World 2 start out in the following positions:

[](images/w2-bros-starting-lg.png)

# No-death Early Hammer

A no-death Early Hammer is the situation where the Hammer moves across 2-3 after the player completes the fort. Due to the rules hammer brothers follow when they move, the only way for this to occur is for both the Hammer and the Music Box to land on top of each other so that they march together to the left across 2-3.

After completing 2-1, the Hammer must move up and the Music Box must move to the right (he can go either up or down at 2-sun, it doesn't matter).

[pic showing how each bro can move after 2-1]

After 2-2, the Hammer must go up again, and the Music Box must end up between the mushroom house and 2-4.

[pic showing how each bro can move after 2-2]

After 2-fort, the Hammer must go left across 2-4, and the Music box must move to the mushroom house and back so that both the Hammer and Music Box end up on the same tile. At this point, they have the chance to walk together down to 2-sun, left twice to 2-3, and then split so that both end up accessible to the player without playing 2-3.

# Hammer Brother Movement Mechanics and Rules

Hammer Brothers and other overworld map objects (the HELP sprite, the World 7 nippers, the spade card game, etc) are tracked in an array of up to 15 different objects. Each object is referenced by its index into the array. The World 2 Boomerang Brothers are index 2 and 3.

Hammer Brother movement is determined by the random number array on multiple frames. Mario 3's random numbers are stored in a 9-byte array. The 72-bits of the 9-byte array are shifted right through the array, with input bits being determined by an XOR-feedback of bit 6 and 14. On each frame, the bits are shifted right once. There are a couple exceptions to this (most notably, lag frames), but that is outside the scope of this document. Although the random number array contains 9 bytes, the very first one is never used, most likely due to its functionality as the "seed" byte. When needing a single random number check, the game typically looks at the second byte in the array.

After a level ends, the game transitions through a number of states to clean things up and get ready for the player to move around on the overworld map. During one of these states, an initial direction is chosen for the Hammer Brother to face. In a later state, the Hammer Brother movement is decided, possibly requiring the Hammer Brother to move multiple times. To decide which direction the Hammer Brother faces, the byte corresponding to the Hammer Brother's object index is chosen from the random number array. The random number array is indexed off of the second byte so that the first byte is not used. The two least-significant bits from the random byte chosen for the given hammer brother are used to determine the direction it is facing. 0 = Right, 1 = Left, 2 = Down, and 3 = Up. 

However, the hammer brother sprites can only face left or right, since there is no up- or down-facing sprite. If the Hammer Brother is facing Right (0), the right-facing sprite will be used. In all other cases, the left-facing sprite will be used. So although the hammer brother may look like it is facing left, its true direction may be left, down, or up. This is important because a hammer brother will choose to march in the opposite direction of the way it is facing only if it has tried to move in all the other directions first.

As an example, if the array of random numbers contains [0x38 0x50 0x20 0x80 0xC1 0xC0 0x43 0xC3 0x44], the music box bro (index 2) will choose byte 0x80 (two bytes from the 2nd byte in the random array). The two least-significant bits of 0x80 are 0b00, so the music box bro will face right.

Some number of frames later (variable depending upon what needs to be done during the intermediate states), the first movement for the Hammer Brother marching is decided. The logic to do this is somewhat complicated, but it boils down to a fairly simple set of rules. The random number array is again accessed in the same way it was for the initial direction determination. The two least-significant bits are used again to decide direction to march. The most-significant bit of the random byte is used to determine if the value will be incremented or decremented while trying directions. If it is a 1, the value will be incremented. If it is a 0, it will be decremented.

For example, if the array of random numbers contains [0x21 0xD3 0x90 0xb7 0x17 0x79 0x57 0xA5 0x0A], the music box bro (index 2) will choose byte 0xb7 (two bytes from the 2nd byte in the random array). The most-significant bit of 0xb7 is 0b1, so the direction value will be incremented while checking the directions until a valid direction is found. The two least-significant bits of 0xb7 are 0b11 (decimal 3, Up). The first direction tried will be the value incremented by 1. 3 + 1 is 4, but only the two least significant bytes are ever looked at, so decimal 4 = binary 0b100, the bottom two bits being 0b00 (Right). The game then checks the direction chosen to see if the Hammer Brother is allowed to walk that way. If it can't march right, it will then choose left (1). However, a hammer brother will not try the direction opposite of the one it is facing unless that is its only option. In our example, the music box bro originally faced right, so it will not move left until that is its last option. So it first checks down (2), then up (3).