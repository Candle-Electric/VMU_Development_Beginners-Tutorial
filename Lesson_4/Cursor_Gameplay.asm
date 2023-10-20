;=======================;
;       Gameplay        ;
;=======================;
; start:	Cursor_Gameplay:
	test_sprite_x				=		$6		; 1 Byte ; Moving These Three To "Cursor_Gameplay."
	test_sprite_y				=		$7		; 1 Byte
	test_sprite_sprite_address	=		$8		; 2 Bytes

; Set Sprite Addresses
	mov	#20, test_sprite_x
	mov	#12, test_sprite_y
	mov	#<Example_Sprite_Mask, test_sprite_sprite_address
	mov	#>Example_Sprite_Mask, test_sprite_sprite_address+1

Cursor_Gameplay: ; Rename To Cursor_Gameplay_Loop:
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
	bp acc, T_BTN_RIGHT1, .Draw_Screen
	ld test_sprite_x
	sub #40
	bn acc, 7, .Draw_Screen
	inc test_sprite_x
.Draw_Screen
	P_Draw_Background_Constant Hello_World_BackGround
	P_Draw_Sprite_Mask test_sprite_sprite_address, test_sprite_x, test_sprite_y
	P_Blit_Screen
	jmpf Cursor_Gameplay
