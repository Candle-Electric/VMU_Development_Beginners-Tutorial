# Lesson 5: Putting It All Together: Let's Make A Game!

Now, let's try adding up everything we've learned so far, and upgrade our Program from "Dragging A Cursor Around" to something more akin to a Full Game. In the vein of the phenomenal [MegaRunner](https://www.ohsat.com/tutorial/megarunner/megarunner-1/) by Andrej Preradovic (A.K.A. [Ohsat](https://www.ohsat.com/).), let's try making it a Side-Scrolling, Infinite Runner type of Game!

## Collision Calculation Within A Range

We can start off by editing our movable "Cursor" from the last lesson into our playable "Character" in this one. Rather than colliding with just the edges of the screen, we'll want to check collision with both the floor and our obstacles; the former will be calculated similarly, and the latter will be a new thing for us to learn. Rather than cycling between the .ASM Files on every press as last time, we'll swap our Face Buttons to Jump now. We'll also "Animate" our Character Sprite later, with Different Graphics For Different Actions. We'll Comment Out our Menu, and Jump straight into our Gameplay while we Code it Up.

Inside our Gameplay Loop, we'll refactor the bottom of the screen's collision detection to now be the "Floor" of our Infinite Runner. Our "Jump" Button can increase the Y-Position (or technically decrease it, since 0 is at the top), like pressing "Up" did before, but in a larger increment initially. Then, "Gravity" can pull the Sprite back down to the Floor, by subtracting an "Accelerated" Value from the Y-Position.

        player_sprite_y   = $19 ; 1 Byte
        player_y_velocity = $1a ; 1 Byte
        ...
        Runner_Gameplay_Loop:
                ; Check Input
	        callf Get_Input ; This Function Is In LibKCommon.ASM
	        ld p3
        .Check_Up
	        ; bp acc, T_BTN_UP1, .Check_Down ; Commenting the Up and Down Buttons out for now.
        .Check_Down
	        ;ld p3
	        ;bp acc, T_BTN_DOWN1, .Check_Left
        .Check_Left
	        ld p3
	        bp acc, T_BTN_LEFT1, .Check_Right
	        ld test_sprite_x
	        sub #2
	        bp acc, 7, .Check_Right
	        dec test_sprite_x
        .Check_Right
	        ld p3
	        bp acc, T_BTN_RIGHT1, .Check_Buttons
	        ld test_sprite_x
	        sub #40
	        bn acc, 7, .Draw_Screen
	        inc test_sprite_x
        .Check_Buttons
	        ld p3
	        bp acc, T_BTN_A1, .Skip_Jump
        	ld test_sprite_y
	        sub #24
	        bnz .Skip_Jump
	        mov #5, runner_jump_acceleration
	.Skip_Jump
	        ld test_sprite_y
	        sub runner_jump_acceleration
	        st test_sprite_y
	        dec runner_jump_acceleration
	        ld runner_jump_acceleration
	.Check_Ground
	        ld test_sprite_y
	        sub #24
	        bp acc, 7, .Skip_Grounded
	        mov #24, test_sprite_y
	        mov #0, runner_jump_acceleration
	.Skip_Grounded
	.skip_Floor_Collision
		jmpf .Main_GamePlay_Loop

As mentioned before, Collision Detection with Obstacles will be a little different. This is because with boundaries such as the Walls and Floor, we're only worried about One Direction. Here, though, we need to worry about All 4 Cardinal Directions. In other words, before we had something like "is X < 48?" For the Right Wall, whereas now we'll have "Is 21 < X < 23 &AND& Is 14 < Y 16?" instead, with the range being determined by the height or width of the object and what it's being collided with. In Assembly, that'll look like this:

        obstacle_sprite_x = $10
        ...
        .Check_Obstacle_Collision
        .Check_Up
                ld player_sprite_y
                sub obstacle_sprite_y
                sub obstacle_size_y
                bp acc, 7, .Check_Bottom
        .Check_Bottom
                ld player_sprite_y
                sub obstacle_sprite_y
                bp acc, 7, .Check_Left ; .Check_Sides
                ; Set The Collision Flag
        .Check_Left
                ld player_sprite_x
                sub obstacle_sprite_x
                sub obstacle_size_x
                bp acc, 7, .Check_Right
        .Check_Right
                ld player_sprite_x
                sub obstacle_sprite_x
                bn acc, 7, .Collision_Done
                ; Set The Collision Flag
        .Collision_Done

While for collision before, we would simply move the Player Object back in bounds, now we will be setting a Flag and then deciding what to do when it's set. Since collision is a Binary "On" or "Off" Value right now, we could use All 8 Bits of a Variable for Different Flags, but for now we'll simply have a Value Assigned as "0" or "1" and compute from there.

        collision_flags = $1b ; 1 Byte
        ...
        mov #0, collision_flags
        ...
        ld collision_flags
        bn acc, 7, .Collision_Done
        mov #1, collision_flags ; Set The Collision Flag

Then, with that Collision Flag Set, we can decide what to do with it, or continue on like nothing happened (because nothing _did_ happen!) if it's Not Set. It basically works the same as checking for button presses did earlier:

        ld collision_flags
        bnz .Collison_Flag_Not_Set
        ; Do whatever you'd like upon collision here!
        .Collision_Flag_Not_Set

There are several things we can do when Collision is Detected for this Auto Runner. For example, we could decrement a Health Bar or Lives Counter, or Display an Animation, or do all of the above.

        num_lives = $1c
        ...
        ld num_lives
        bz .Continue_Playing
        mov #<Game_Over_Text, acc ; Could Play a "Game Over" Animation here, if you'd like!
        ret ; This way, we can Return to the Title Screen when the Player's Game is Finished!
        .Continue_Playing

Animating the Sprites will be a fun process. While we won't have animation files, we will be using a "State Machine" similarly to how the many excellent tutorials for Unity and other Engines often handle it. Then, we can `#mov` each Frame for the Distinct Animations based on which State we're in, and that requisite image will be drawn when we blit the screen and call LibPerspective.

        run_frame = $1d
        ...
        inc run_frame
        bp run_frame, 2, .Reset_Run_Frame
        jmpf .Continue_Running
        .Rest_Run_Frame
        mov #0, run_frame
        .Continue_Running
        ...
        .Run_Frame_0
        ld run_frame
        bnz .Run_Frame_1
        mov #<Run_Frame_0, acc
        st Player_Sprite_Address
        .Run_Frame_1
        ld run_frame
        sub #1
        bnz .Run_Frame_2
        mov #<Run_Frame_1, acc
        st Player_Sprite_Address
        .Run_Frame_2 ; And So On...
        ...
        P_Draw_Sprite_Mask Player_Sprite_Address, player_Sprite_x, player_sprite_y
