;=======================;
;       Gameplay        ;
;=======================;
Cursor_Gameplay:
	test_sprite_x			=		$6		; 1 Byte ; Moving These Three To "Cursor_Gameplay."
	test_sprite_y			=		$7		; 1 Byte
	test_sprite_sprite_address	=		$8		; 2 Bytes

; Set Sprite Addresses
	mov	#20, test_sprite_x
	mov	#12, test_sprite_y
.Draw_Example_Character_1
	ld	character_flags
	bnz	.Draw_Example_Character_2
	mov	#<Example_Sprite_Mask, test_sprite_sprite_address
	mov	#>Example_Sprite_Mask, test_sprite_sprite_address+1
	jmpf	Cursor_Gameplay_Loop
.Draw_Example_Character_2
	ld	character_flags
	sub	#1
	bnz	.Draw_Example_Character_3
	mov	#<Example_Sprite_Mask, test_sprite_sprite_address
	mov	#>Example_Sprite_Mask, test_sprite_sprite_address+1
	jmpf	Cursor_Gameplay_Loop
.Draw_Example_Character_3
	ld	character_flags
	sub	#2
	bnz	.Cursor_Gameplay_Loop
	mov	#<Example_Sprite_Mask, test_sprite_sprite_address
	mov	#>Example_Sprite_Mask, test_sprite_sprite_address+1

Cursor_Gameplay_Loop:
; Check Input
	callf Get_Input ; This Function Is In LibKCommon.ASM
	ld p3
.Check_Up
	bp acc, T_BTN_UP1, .Check_Down
	ld test_sprite_y
	sub #1
	bp acc, 7, .Check_Down
	dec test_sprite_y
.Check_Down
	callf Get_Input
	ld p3
	bp acc, T_BTN_DOWN1, .Check_Left
	ld test_sprite_y
	sub #24
	bn acc, 7, .Check_Left
	inc test_sprite_y
.Check_Left
	callf Get_Input
	ld p3
	bp acc, T_BTN_LEFT1, .Check_Right
	ld test_sprite_x
	sub #2
	bp acc, 7, .Check_Right
	dec test_sprite_x
.Check_Right
	callf Get_Input
	ld p3
	bp acc, T_BTN_RIGHT1, .Check_Buttons
	ld test_sprite_x
	sub #40
	bn acc, 7, .Draw_Screen
	inc test_sprite_x
.Check_Buttons ; Return To The "Main Menu/Pause Menu" If The Player Presses A Or B
	callf Get_Input
	ld p3
	bn acc, T_BTN_A1, .Return_To_Menu
	bn acc, T_BTN_B1, .Return_To_Menu
	jmpf .Draw_Screen
.Return_To_Menu
	ret ; Leave `Cursor_Gameplay.ASM` And Return To `Main_Menu.ASM`, As Per `Main.ASM`'s Main Loop.
.Draw_Screen
.Draw_Example_Stage_1
	ld stage_flags
	bnz .Draw_Example_Stage_2
	P_Draw_Background_Constant Hello_World_BackGround
	jmpf .Draw_Character
.Draw_Example_Stage_2
	ld stage_flags
	sub #1
	bnz .Draw_Example_Stage_3
	P_Draw_Background_Constant Hello_World_BackGround
	jmpf .Draw_Character
.Draw_Example_Stage_3
	ld stage_flags
	sub #2
	bnz .Draw_Character
	P_Draw_Background_Constant Hello_World_BackGround
.Draw_Character
	P_Draw_Sprite_Mask test_sprite_sprite_address, test_sprite_x, test_sprite_y
	P_Blit_Screen
	jmpf Cursor_Gameplay_Loop
