;=======================;
;         Menu          ;
;=======================;
Runner_Menu:
	cursor_1_val			=		$6
	cursor_2_val			=		$7
	cursor_y_pos			=		$8
Menu_Loop:
	callf Get_Input
	P_Draw_Sprite	cursor_sprite_address, b, c
	ret

