# Lesson 5: Putting It All Together: Let's Make A Game!

Now, let's try adding up everything we've learned so far, and upgrade our Program from "Dragging A Cursor Around" to something more akin to a Full Game. In the vein of the phenomenal [MegaRunner](https://www.ohsat.com/tutorial/megarunner/megarunner-1/) by Andrej Preradovic (A.K.A. [Ohsat](https://www.ohsat.com/).), let's try making it a Side-Scrolling, Infinite Runner type of Game!

We can start off by editing our movable "Cursor" from the last lesson into our playable "Character" in this one. Rather than colliding with the edges of the screen, we'll want to check collision with both the floor and our obstacles; the former will be calculated similarly, and the latter will be a new thing for us to learn. Rather than cycling between the .ASM Files on every press as last time, we'll swap our Face Buttons to Jump now. We'll also "Animate" our Character Sprite now, with Different Graphics For Different Actions. We'll Comment Out our Menu, and Jump straight into our Gameplay while we Code it Up.

Inside our Gameplay Loop, we'll refactor the bottom of the screen's collision detection to now be the "Floor" of our Infinite Runner. Our "Jump" Button can increase the Y-Position, like pressing "Up" did before, but in a larger increment initially. Then, "Gravity" can pull the Sprite back down to the Floor, by subtracting an "Accelerated" Value from the Y-Position.

        player_sprite_y   = $19 ; 1 Byte
        player_y_velocity = $1a ; 1 Byte
        ...
    .Main_GamePlay_Loop
        callf Get_Input
        ld p3
        bn acc, BTN_B, .skip_jump
        ...
        ld player_sprite_y
        bnz .skip_jump ; Only Jump IF Player Character's On The Ground.
        ; When Jumping:
        mov #3, player_y_velocity
    .skip_jump
        ...
        ld player_sprite_y
        add player_y_velocity
        st player_sprite_y
        ld player_y_velocity
        sub #1
        st player_y_velocity
        ld player_sprite_y
        bn acc, 7, .skip_floor_collision
        mov #0, player_sprite_y
    .skip_Floor_Collision
        jmpf .Main_GamePlay_Loop

As mentioned before, Collision Detection with Obstacles will be a little different. This is because with boundaries such as the Walls and Floor, we're only worried about One Direction. Here, though, we need to worry about All 4 Cardinal Directions. In other words, before we had something like "is X < 48?" For the Right Wall, whereas now we'll have "Is 21 < X < 23 &AND& Is 14 < Y 16?" instead, with the range being determined by the height or width of the object being collided with. In Assembly, that'll look like this:

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

While for collision before, we would simply move the Player Object back in bounds, now we will be setting a Flag and then deciding what to do when it's set.
