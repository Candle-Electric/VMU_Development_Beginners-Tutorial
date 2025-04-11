;=======================;
;         Menu          ;
;=======================;
Runner_Menu:
	cursor_1_val			=		$6
	cursor_2_val			=		$7
	cursor_y_pos			=		$8
	option_1_sprite_address		=		$9
Menu_Loop:
	callf Get_Input
.Check_Up 
	ld p3
	mov #Button_Up, acc ; bp acc, 7, ...
	callf Check_Button_Pressed
	bn acc, 0, .Check_Down
	dec cursor_y_pos
	; jmpf .Input_DPad_Done
.Check_Down
	ld p3
	mov #Button_Down, acc
	callf Check_Button_Pressed
	bn acc, 1, .Check_Left
.Check_Left
	ld p3
	mov #Button_Left, acc
	callf Check_Button_Pressed
.Check_Right
	ld p3
	mov #Button_Right, acc
	callf Check_Button_Pressed
.Draw_Screen
	P_Draw_Sprite	cursor_sprite_address, b, c
	ret

