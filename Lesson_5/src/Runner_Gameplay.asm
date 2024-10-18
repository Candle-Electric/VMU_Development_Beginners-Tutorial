;=======================;
;       Gameplay        ;
;=======================;
Runner_Gameplay:
	test_sprite_x			=		$6		; 1 Byte ; Moving These Three To "Cursor_Gameplay."
	test_sprite_y			=		$7		; 1 Byte
	test_sprite_sprite_address	=	$8		; 2 Bytes
	ones_digit	=	$1a
	tens_digit	=	$1b
	hundreds_digit	=	$1c
	thousands_digit	=	$1d
	score		=	$1e
	digit_sprite_address = $1f
	runner_jump_acceleration = $21
	jump_accel_positive = $22
	obstacle_sprite_address = $23
	obstacle_sprite_x = $25
	obstacle_sprite_y = $26
	frame_counter = $27
	collision_flags = $28

; Populate Character And Stage Flags
	; ld cursor_flags
	; ld stage_flags
; Set Sprite Addresses
	mov	#20, test_sprite_x
	mov	#12, test_sprite_y
	mov #32, obstacle_sprite_x
	mov #12, obstacle_sprite_y
	mov #0, runner_jump_acceleration
	mov #0, jump_accel_positive
	mov #0, frame_counter
.Draw_Example_Character
	; ld	character_flags
	; bnz	.Draw_Example_Character_2
	mov	#<Example_Sprite_Mask, test_sprite_sprite_address
	mov	#>Example_Sprite_Mask, test_sprite_sprite_address+1
	; jmpf	Runner_Gameplay_Loop
	mov	#<obstacle_sprite_mask, obstacle_sprite_address
	mov	#>obstacle_sprite_mask, obstacle_sprite_address+1

Runner_Gameplay_Loop:
; Check Input
	callf Get_Input ; This Function Is In LibKCommon.ASM
	ld p3
.Check_Up
	; bp acc, T_BTN_UP1, .Check_Down
	; ld test_sprite_y
	; sub #1
	; bp acc, 7, .Check_Down
	; dec test_sprite_y
.Check_Down
	;callf Get_Input
	;ld p3
	;bp acc, T_BTN_DOWN1, .Check_Left
	;ld test_sprite_y
	;sub #24
	; bn acc, 7, .Check_Left
	; inc test_sprite_y
.Check_Left
	; callf Get_Input
	ld p3
	bp acc, T_BTN_LEFT1, .Check_Right
	ld test_sprite_x
	sub #2
	bp acc, 7, .Check_Right
	dec test_sprite_x
.Check_Right
	; callf Get_Input
	ld p3
	bp acc, T_BTN_RIGHT1, .Check_Buttons
	ld test_sprite_x
	sub #40
	bn acc, 7, .Draw_Screen
	inc test_sprite_x
.Check_Buttons
	; callf Get_Input
	ld p3
	bp acc, T_BTN_A1, .Skip_Jump
	; bn acc, T_BTN_B1, .Return_To_Menu
	ld test_sprite_y
	sub #24
	bnz .Skip_Jump
	mov #5, runner_jump_acceleration
	; jmpf .Draw_Screen
.Skip_Jump ; .Return_To_Menu
	ld test_sprite_y
	sub runner_jump_acceleration
	st test_sprite_y
	; ld runner_jump_acceleration
	dec runner_jump_acceleration
	ld runner_jump_acceleration
	
	; bp acc, 7, .Check_Ground
	; sub #1
	; st runner_jump_acceleration
.Check_Ground
	ld test_sprite_y
	sub #24
	bp acc, 7, .Skip_Grounded
	mov #24, test_sprite_y
	mov #0, runner_jump_acceleration
.Skip_Grounded
	inc frame_counter
	dec obstacle_sprite_x;
	bn obstacle_sprite_x, 7, .Skip_Arrow_Reset
	mov #47, obstacle_sprite_x
	ld frame_counter
	st c
	mov #0, acc
	mov #7, b
	div
	ld c
	add #20
	st obstacle_sprite_y
.Skip_Arrow_Reset
.Check_Obstacle_Collision
	mov #0, collision_flags
.Check_Up_Collision
		ld test_sprite_y
		sub obstacle_sprite_y
		sub #3 ; obstacle_size_y
		bp acc, 7, .Check_Left_Collision
.Check_Bottom_Collision
		ld test_sprite_y
		sub obstacle_sprite_y
		bn acc, 7, .Check_Left_Collision ; .Check_Sides
		set1 collision_flags, 0 ; Set The Collision Flag
.Check_Left_Collision
		ld test_sprite_x
		sub obstacle_sprite_x
		sub #3 ; obstacle_size_x
		bp acc, 7, .Check_Right_Collision
.Check_Right_Collision
		ld test_sprite_x
		sub obstacle_sprite_x
		add #3
		bn acc, 7, .Collision_Done
		set1 collision_flags, 1		; Set The Collision Flag
.Collision_Done
	ld collision_flags
	sub #3
	bnz .Collision_No
.Collision_Yes
	mov #<Example_Sprite_Mask, test_sprite_sprite_address
	mov	#>Example_Sprite_Mask, test_sprite_sprite_address+1
	jmpf .Draw_Screen
.Collision_No
	mov #<Obstacle_Sprite_Mask, test_sprite_sprite_address
	mov	#>Obstacle_Sprite_Mask, test_sprite_sprite_address+1
.Draw_Screen
.Draw_Example_Stage_1
	; ld stage_flags
	; bnz .Draw_Example_Stage_2
	P_Draw_Background_Constant ExampleBG_City
	jmpf .Draw_Character
.Draw_Example_Stage_2
	; ld stage_flags
	; sub #1
	; bnz .Draw_Example_Stage_3
	; P_Draw_Background_Constant ExampleBG_Jungle
	jmpf .Draw_Character
.Draw_Example_Stage_3
	; ld stage_flags
	; sub #2
	; bnz .Draw_Character
	; P_Draw_Background_Constant Hello_World_BackGround
.Draw_Character
	P_Draw_Sprite_Mask test_sprite_sprite_address, test_sprite_x, test_sprite_y
.Draw_Obstacle
	P_Draw_Sprite_Mask obstacle_sprite_address, obstacle_sprite_x, obstacle_sprite_y
	P_Blit_Screen
	jmpf Runner_Gameplay_Loop

; Draw_Digit:
; 	; b = the X-Position, c = the Number
; .Digit_0  
; 	ld c
; 	bnz .Digit_1
; 	mov #<Digit_0, digit_sprite_address
; 	mov #>Digit_0, digit_sprite_address+1
; 	jmpf .Digit_Decided
; .Digit_1
; 	ld c
; 	sub #1
; 	bnz .Digit_2
; 	mov #<Digit_1, digit_sprite_address
; 	mov #>Digit_1, digit_sprite_address+1
; 	jmpf .Digit_Decided
; .Digit_2
; 	ld c
; 	sub #2
; 	bnz .Digit_3
; 	mov #<Digit_2, digit_sprite_address
; 	mov #>Digit_2, digit_sprite_address+1
; 	jmpf .Digit_Decided
; .Digit_3
; 	ld c
; 	sub #2
; 	bnz .Digit_4
; 	mov #<Digit_3, digit_sprite_address
; 	mov #>Digit_3, digit_sprite_address+1
; 	jmpf .Digit_Decided
; .Digit_4
; 	ld c
; 	sub #2
; 	bnz .Digit_5
; 	mov #<Digit_4, digit_sprite_address
; 	mov #>Digit_4, digit_sprite_address+1
; 	jmpf .Digit_Decided
; .Digit_5
; .Digit_Decided
; 	mov #0, c ; Every Digit will be at the top of the screen.
; 	P_Draw_Sprite digit_sprite_address, b, c
; 	ret
; 	
; %macro Draw_Score
; 	mov #16, b
; 	ld ones_digit
; 	st c
; 	callf Draw_Digit
; 	mov #24, b
; 	ld tens_digit
; 	st c
; 	callf Draw_Digit
; 	mov #32, b
; 	ld hundreds_digit
; 	st c
; 	callf Draw_Digit
; 	mov #40, b
; 	ld thousands_digit
; 	st c
; 	callf Draw_Digit
; %end	