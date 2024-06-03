; Lesson 5
    player_sprite_y   = $19 ; 1 Byte
    player_y_velocity = $1a ; 1 Byte
    ; ...
    start:
.Main_GamePlay_Loop ;:
    callf Get_Input
    ld p3
    bn acc, BTN_B, .skip_jump
    ; ...
    ld player_sprite_y
    bnz .skip_jump ; Only Jump IF Player Character's On The Ground.
    ; When Jumping:
    mov #3, player_y_velocity
.skip_jump
    ; ...
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
    ; Blit Screen, Etc.
    jmpf .Main_GamePlay_Loop
