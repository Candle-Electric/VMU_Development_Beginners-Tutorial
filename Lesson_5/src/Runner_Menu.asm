;=======================;
;         Menu          ;
;=======================;
Runner_Menu:
	cursor_1			=		$6
	cursor_2			=		$7

Menu_Loop:
	P_Draw_Sprite	cursor_sprite_address, b, c
	ret

