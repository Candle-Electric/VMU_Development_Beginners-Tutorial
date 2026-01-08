# Lesson 5: Putting It All Together: Let's Make A Game!

Now, let's try adding up everything we've learned so far, and upgrade our Program from "Dragging A Cursor Around" to something more akin to a Full Game. In the vein of the phenomenal [MegaRunner](https://www.ohsat.com/tutorial/megarunner/megarunner-1/) by Andrej Preradovic (A.K.A. [Ohsat](https://www.ohsat.com/).), let's try making it a Side-Scrolling, Infinite Runner type of Game!

## Collision Calculation Within A Range

We can start off by editing our movable "Cursor" from the last lesson into our playable "Character" in this one. Rather than colliding with just the edges of the screen, we'll want to check collision with both the floor and our obstacles; the former will be calculated similarly, and the latter will be a new thing for us to learn. Rather than having them cycle between the .ASM Files on every press as last time, we'll swap our Face Buttons to Jump now, so that the player can avoid the Obstacle Object. We'll also "Animate" our Character Sprite later, with Different Graphics For Different Actions. To start out, we'll Comment Out our Menu, and Jump straight into our Gameplay while we Code it Up.

Inside our Gameplay Loop, we'll refactor the bottom of the screen's collision detection to now be the "Floor" of our Infinite Runner. Meanwhile, we'll keep the left and right "Walls" as boundaries for our player character to move within horizontally, as well as the same code for our left and right controls. Up and down are going to be commented out for now, since the character will be grounded while running. Button A can be our "Jump" Button to increase the Y-Position (or technically decrease it, since 0 is at the top), like pressing "Up" did before, but in a larger increment initially. 

        player_sprite_x   = $18
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
	    .Calculate_Gravity
			; To-Do
        .Check_Ground
	        ld test_sprite_y
	        sub #24
	        bp acc, 7, .Skip_Grounded
	        mov #24, test_sprite_y
        .Skip_Grounded
        .Skip_Floor_Collision
		jmpf .Main_GamePlay_Loop

Then, "Gravity" can pull the Sprite back down to the Floor, by subtracting an "Accelerated" Value from the Y-Position, namely the new variable we instantiated just before. Every Frame, we'll decrement this, and when it rolls over past zero, the overload will take care of it for us, adding its value, + have the Player change from rising to falling.

	.Skip_Jump
	.Calculate_Gravity
		ld test_sprite_y
		sub runner_jump_acceleration
		st test_sprite_y
		dec runner_jump_acceleration
		; ld runner_jump_acceleration
	.Check_Ground
		...	; Same As Before, But...
	    ld test_sprite_y
	    sub #24
	    bp acc, 7, .Skip_Grounded
		; Now, when we're Grounded, we'll Reset the Acceleration to Zero, too.
	    mov #24, test_sprite_y
		mov #0, runner_jump_acceleration ; Reset The Acceleration To Zero On The Ground.

Next, let's make an "Obstacle" object for our Player Character to collide with and jump over. As mentioned before, Collision Detection with Obstacles will be a little different. This is because with boundaries such as the Walls and Floor, we're only worried about One Direction. Here, though, we need to worry about All 4 Cardinal Directions. In other words, before we had something like "is X < 48?" For the Right Wall, whereas now we'll have "Is 21 < X < 23 &AND& Is 14 < Y 16?" instead, with the range being determined by the height or width of the object and what it's being collided with. In Assembly, that'll look like this:

        	   obstacle_sprite_x = $10
               onstacle_sprite_y = $11
        ...
        .Check_Obstacle_Collision
        .Check_Up
                ld player_sprite_y
                sub obstacle_sprite_y
                sub obstacle_size_y
                bp acc, 7, .Check_Bottom
				; Set Th eTop Collision Flag
        .Check_Bottom
                ld player_sprite_y
                sub obstacle_sprite_y
                bp acc, 7, .Check_Left ; .Check_Sides
                ; Set The Bottom Collision Flag
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

Before each next direction's section is started, you may notice the Comments to set the Collision Flags. What this means is, that since we're now looking for a range of collision, both of the flags for a given direction have to be set for the collision boolean to be true. So, for the "21 < X < 23" example above, X needs to be larger than 21 _and_ smaller than 23. This means that it's in the X-Range of collision. Then, we can do the same + see if it's between 14 and 16 for Y.While for collision before, we would simply move the Player Object back in bounds, now we will be setting a Flag and then deciding what to do when it's set. Since collision is a Binary "On" or "Off" Value right now, we could use All 8 Bits of a Variable for Different Flags, but for now we'll simply have a Value Assigned as "0" or "1" and compute from there.

        collision_flags = $1b ; 1 Byte
        ...
        mov #0, collision_flags
        ...
        ld collision_flags
        bn acc, 7, .Collision_Done ; BNZ
        mov #1, collision_flags ; Set The Collision Flag

To start, we'll have that Flag as 1, meaning a Collision is Active. If any of the Collision Range checks aren't met, then we'll reset it to 0.

	; PseudoCode Goes Here
			top_collision_flag = $1f ; 1 Byte
			bottom_collision_flag = $20 ; 1 Byte
			left_collision_flag = $21 ; 1 Byte
			right_collision_flag = $27 ; 1 Byte
		.....
        .Check_Obstacle_Collision ; Note: See If this Works with 1 Flag And Jumps Only.
				mov #0, top_collision_flag ; And The Rest!
				mov #0, bottom_collision_flag
				mov #0, left_collision_flag
				mov #0, right_collision_flag
        .Check_Up
                ld player_sprite_y
                sub obstacle_sprite_y
                sub obstacle_size_y
                bp acc, 7, .Check_Bottom
				mov #1, top_collision_flag ; Set The Top Collision Flag
        .Check_Bottom
                ld player_sprite_y
                sub obstacle_sprite_y
                bp acc, 7, .Check_Left ; .Check_Sides
                mov #1, bottom_collision_flag ; Set The Bottom Collision Flag
        .Check_Left
                ld player_sprite_x
                sub obstacle_sprite_x
                sub obstacle_size_x
                bp acc, 7, .Check_Right
				mov #1, left_collision_flag ; Set The Bottom Collision Flag
        .Check_Right
                ld player_sprite_x
                sub obstacle_sprite_x
                bn acc, 7, .Collision_Done
                mov #1, right_collision_flag ; Set The Collision Flag
        .Collision_Done

Then, with that Collision Flag Set, we can decide what to do with it, or continue on like nothing happened (because nothing _did_ happen!) if it's Not Set. It basically works the same as checking for button presses did earlier:

        	ld collision_flags
        	bnz .Collison_Flag_Not_Set
        	; Do whatever you'd like upon collision here!
        .Collision_Flag_Not_Set


			; Alternatively,
			ld top_collision_flag
			add bottom_collision_flag
			add left_collision_flag
			add right_collision_flag
			ld acc
			bnz .Collision_Flag_Not_Set
		.Collision_Flag_Alternatively_Not_Set

There are several things we can do when Collision is Detected for this Auto Runner. For example, we could decrement a Health Bar or Lives Counter, or Display an Animation, or do all of the above.

        	num_lives = $1c
        	...
        	ld num_lives
        	bnz .Continue_Playing
        	mov #<>Game_Over_Text, acc ; Could Play a "Game Over" Animation here, if you'd like!
        	ret ; This way, we can Return to the Title Screen when the Player's Game is Finished!
        .Continue_Playing

We'll start by swapping the Player Character's Sprite when Collision is Active. This is doubly helpful, because it gives us a great opportunity to test the "bounds" of the collision box by keeping the obstacle static and moving our player character around it, recompiling each time to test the coded values or alternatively introducing a new variable to change in each instance, as well as an easy visual indicator for Debugging. It will also give us a start into our next topic, sprite animation.

	 	player_width_x = $1a ; instantiate a "Player Sprite Width" variable
		...
		mov #3, player_width_x ; This can be changed before every Rebuild for easy tweaking!
		...
	.Collision_Up ; , Down, Left
		; Left = Add
	.Collision_Right
		ld Player_Sprite_X ; collision_flags
		sub Obstacle_Sprite_X
		sub #3 ; alternatively, could call the assigned width above with "sub player_width_x"
		bn acc, 7, .Collision_Checks_Done
		mov #1, Collision_Flag_Right
		; To-Do: Add Code + Explanation For Bounding Box.
		bnz .Collision_No
		add #6
		bp acc, 7, .Collision_No
	.Collision_Yes
		mov #<Obstacle_Sprite_Hit, test_sprite_sprite_address
		mov #>Obstacle_Sprite_Mask, test_sprite_sprite_address+1
		jmpf .Draw_Screen
	.Collision_No
		mov #<Example_Sprite_Mask, test_sprite_sprite_address
		mov #>Example_Sprite_Mask, test_sprite_sprite_address+1
	.Draw_Screen
		P_Draw_Sprite test_sprite_x, test_sprite_y, test_sprite_address ; This Address Will Be Filled In By The Above Code!
		...

Then, we can have the obstacle move sideways across the screen for us to interact with:

	dec obstacle_sprite_x ; Single Speed
	; dec obstacle_sprite_x ; Uncomment For Double Speed

It's tough to jump over the obstacle if it's moving a 1 Pixel Per Second, so we can mess around with its speed value. For example, we can move it at single or double speed in the Code Block Above.

## Animating Sprites

Next, we can up this set of two images to a larger number, and think of them as the first two frames in a larger sequence that we can build on. Animating the Sprites will be a fun process. While we won't have animation files per se, we will be using a "State Machine" similarly to how the many excellent tutorials for Unity and other Engines often handle it. We can start by instantiating a new variable, that will increment each Frame. Then, we can `#mov` each Frame for the Distinct Animations based on which State we're in, in tandem with the Frame Counter, and that requisite image will be drawn when we blit the screen and call LibPerspective. Later, If we want to use more Bits of the Frame Counter than Just the number we have for the Animation, we can Do Bitwise Check Operands to do our Jumps. For example, we can see if the Second Bit is Set to check #s 3 and 4.

        run_frame = $1d ; Frame Counter to determine which # Of Animation Images' Sequence to Draw.
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
			; bp Bits 0 & 1
			; bp frame_counter, 1, .Run_Frame_2
        	mov #<Run_Frame_0, Player_Sprite_Address
        	mov #>Run_Frame_0, Player_Sprite_Address
			jmpf .Draw_Player_Character
        .Run_Frame_1
        	ld run_frame
        	sub #1
        	bnz .Run_Frame_2
			bn Frame_Counter, 0, .Drawing_Example_Done
        	mov #<Run_Frame_1, Player_Sprite_Address
        	mov #>Run_Frame_1, Player_Sprite_Address
            jmpf .Draw_Player_Character
        .Run_Frame_2 ; And So On...
			bp run_frame, 0, .Run_Frame_3
        	mov #<Run_Frame_2, Player_Sprite_Address
        	mov #>Run_Frame_2, Player_Sprite_Address
			jmpf .Somewhere
		.Run_Frame_3
			mov #<Run_Frame_3, Player_Sprite_Address
        	mov #>Run_Frame_3, Player_Sprite_Address
			jmpf .Draw_Player_Character
        	...
        P_Draw_Sprite_Mask Player_Sprite_Address, player_Sprite_x, player_sprite_y

Then, we can add assign this animation to a new "State #" Variable as the "Running" state, and add another state on top of it, a "Jumping" one!

		player_state = $22 ; 1 Byte. 0 = Default Value (Running.).
		...
        .Check_Buttons
	        ld p3
	        bp acc, T_BTN_A1, .Skip_Jump
        	ld test_sprite_y
	        sub #24
	        bnz .Skip_Jump
	        mov #5, runner_jump_acceleration
			mov #1, player_state
		...
        .Check_Ground
	        ld test_sprite_y
	        sub #24
	        bp acc, 7, .Skip_Grounded
	        mov #24, test_sprite_y
	        mov #0, runner_jump_acceleration
			mov #0, player_state

With that State Variable set, we can update those "Animation" Loops and Branches to Call it and decide which Animation Frame will show when we Draw the Player Sprite:

	.Draw_Player_Running
		ld player_state
		bnz .Draw_Player_Jumping
		.Run_Frame_1
		.Run_Frame_2
		...
		jmpf .Draw_Player_Sprite
	.Draw_Player_Jumping
		ld player_state
		sub #1
		bnz .Draw_Third_State ; (If we have one)
	.Jump_Frame_1
	.Jump_Frame_2
		...

Then, the Final P_Draw_Sprite will have the "Frame" of Animation, be it running or jumping, ready and stored in its Sprite Address.

	.Draw_Player_Sprite
		P_Draw_Sprite_Mask Player_Sprite_Address, player_sprite_x, player_sprite_y

Next, with one Animation under our belts, we can make another for when the player is hit, and circle back to when we swapped the Graphics on Collision before.

Next, now that we have our player character "moving" in an animated run cycle, we'll get them moving in a new way, jumping! This will be done with an "acceleration" sort of movement. At the start of the Jump, it'll be high, representing the upward movement, and then we'll subtract for "Gravity" on each Frame.

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
			; Check BoundS And Ground.
			; ld Test_Sprite_Y, Sub #24, BN Bit 7.

We'll then use the Ground Collision to reset this value to Zero once the Player's landed.

		ld player_pos_y
		sub #28
		bp acc, 7, .Skip_Ground_Collision
		mov #0, runner_jump_acceleration
		add #3
		mov #28, player_pos_y ; Grounded Position.
	.Skip_Ground_Collision

Also, we'll need to make sure the Player can only leap when their feet are on the ground. Without this check, the Player can jump inifnitely, which has its merits, as characters like Kirby floating, Flappy Bird, or the Ichidant-R Bird Mini Game control. For this Infinite Runner style though, on leap at a time will suffice.

        .Check_Buttons
	        ld p3
	        bp acc, T_BTN_A1, .Skip_Jump
        	ld test_sprite_y
	        sub #24 ; Already Done Here.
	        bnz .Skip_Jump
	        mov #5, runner_jump_acceleration
			mov #1, player_state
		.Skip_Jump
			ld test_sprite_y
			bz .Skip_Acceleration_Calculation
			dec runner_jump_accelerations
			add runner_jump_acceleration
			st test_sprite_y
		.Skip_Acceleration_Calculation

Venturing onward, now that we're jumping, we can utilize this new action in conjunction with the range collision to interact with some obstacles on an X + Y-Position basis. Going towards it and over it are how we'll do that, respectively. Luckily, the X+Y Collision from the "Cursor" Mode earlier can work the same way.
