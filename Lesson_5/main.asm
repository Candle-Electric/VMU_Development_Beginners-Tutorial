;=======================;
;Beginners' VMU Tutorial;
;       Lesson 5        ;
;=======================;

;=======================;
;  Prepare Application  ;
;=======================;
	.org	$00
	jmpf	start

	.org	$03
	reti	

	.org	$0b
	reti	
	
	.org	$13
	reti	

	.org	$1b
	jmpf	t1int
	
	.org	$23
	reti	

	.org	$2b
	reti	
	
	.org	$33
	reti	

	.org	$3b
	reti	

	.org	$43
	reti	

	.org	$4b
	clr1	p3int,0
	clr1	p3int,1
	reti

	.org	$130	
t1int:
	push	ie
	clr1	ie,7
	not1	ext,0
	jmpf	t1int
	pop	ie
	reti

	.org	$1f0

goodbye:	
	not1	ext,0
	jmpf	goodbye

;=======================;
;VMU Application Header ;
;=======================;
.include "GameHeader.i"

;=======================;
;   Include Libraries   ;
;=======================;
.include "./lib/libperspective.asm"
.include "./lib/libkcommon.asm"
.include "./lib/sfr.i"

;=======================;
;  Include  Code Files  ;
;=======================;
.include		"./src/Runner_Gameplay.asm"
; .include		"./Main_Menu.asm"

;=======================;
;   Define Variables:   ;
;=======================;
p3_pressed			=		$4	; 1 Byte (For LibKCommon)
p3_last_input			=		$5	; 1 Byte (For LibKCommon)
character_flags			=		$17	; 1 Byte
stage_flags			=		$18	; 1 Byte
; obstacle_collision_flags	=		$19	; 1 Byte

;=======================;
; Initialize Variables: ;
;=======================;
; mov #0, character_flags
; mov #0, stage_flags

;=======================;
;       Constants       ;
;=======================;
T_BTN_SLEEP				equ		7
T_BTN_MODE				equ		6
T_BTN_B1				equ		5
T_BTN_A1				equ		4
T_BTN_RIGHT1				equ		3
T_BTN_LEFT1				equ		2
T_BTN_DOWN1				equ		1
T_BTN_UP1				equ		0
;=======================;
;     Main Program      ;
;=======================;
start:
    player_sprite_y   = $19 ; 1 Byte
    player_y_velocity = $1a ; 1 Byte
    player_runner_sprite_addr = $1b; 2 Bytes
    ; ...
    start:
    mov #8, player_sprite_y
    mov #0, player_y_velocity
    mov #<Player_Runner_Sprite_Mask, player_runner_sprite_addr 
    mov #>Player_Runner_Sprite_Mask, player_runner_sprite_addr+1
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
.check_Enemy_Collision
    ; Load The Obstacle X First And Skip This If The Location Is On The Right Side Of The Screen, Since That's Way In Advance Of The Player.
    ld player_sprite_x
    ; sub obstacle_1_x
    ; add #2
    ; bp acc, 7, .Left_Collision_Yes ; Then Do The Same, Swap The Arithmetic, And Head To .Right_Collision_Yes And Set The Flag.
    ; jmpf .Done_Colliding
    ; .Left_Collision_Yes
    ; sub #4
    ; bp acc, 7, .Right_Collision_Yes
    ; jmpf .Done_Colliding
    ; .Right_Collision_Yes
    mov #1, obstacle_collision_flags ; (Set The Flag To "Collided.").
    ; ldf obstacle_collision_flags
    ; bz .Done_Colliding
    ; .Done_Colliding
    ; Blit Screen, Etc.
    ; .Draw_Screen
    P_Blit_Screen
    jmpf .Main_GamePlay_Loop
