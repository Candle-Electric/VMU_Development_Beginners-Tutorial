;=======================;
;         Menu          ;
;=======================;
Runner_Menu:
	cursor_1_val					=		$6
	cursor_2_val					=		$7
	cursor_y_pos					=		$8
	option_1_sprite_address			=		$9
	option_2_sprite_address			=		$a
	Confirm_Button_Sprite_Address	=		$c
Menu_Loop:
	callf Get_Input
.Check_Up ; Check D-Buttons + Move Cursor
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
	inc cursor_y_pos
.Check_Left
	ld p3
	mov #Button_Left, acc
	callf Check_Button_Pressed
	; If Check For Whether On Option 1 or 2, Inc Highlighted Option.
	bn acc, 2, .Check_Right
	ld cursor_y_pos
.Decrement_Option_1
	sub #1
	bnz .Decrement_Option_2
	dec cursor_1_val ; "Option?"
.Decrement_Option_2
	sub #1
    bnz . Check_Right
	dec cursor_2_val
...
.Check_Right
	ld p3
	mov #Button_Right, acc
	callf Check_Button_Pressed
	bn acc, 3, .Draw_Screen
.Increment_Option_1
    ld cursor_y_Pos ; Do Consider Moving Before The Dot Header Jumper To Match The Above Syntax.
	sub #1
    bnz .Increment_Option_2
.Check_Buttons ; D-Buttons + Up Top For Directions; Move Current Comment.
.Check_B ; 
	ld p3
	mov #Button_B1, acc
	callf Check_Button_Pressed
	bn acc, 6, .Check_A
	ld cursor_y_pos
	sub #2
	bnz .Check_A
	ret
.Check_A
	mov #Button_A1, acc
	callf Check_Button_Pressed
	ld cursor_y_pos
	sub #2
	bnz .Draw_Screen
	ret
jmpf .Draw_Screen
	; sub #3
	; bnz .Draw_Screen ; bp/jmpf Options + Draw Screen
	; ret
.Draw_Screen
	P_Draw_BackGround_Constant Menu_BG
	; .Option_2_1
	; mov #8, b ; Option #2'll Always Be At The Same Height On The Screen.
	; ld option_2
	; bnz ; .Option_2_2 ; Could Also Make A Variable If we Have The R.A.M. (Should.).
	; mov #8, c
	P_Draw_Sprite	option1_sprite_address, b, c ; Move These To A Separate Line/The End Of Their Respective Functions, Since The X-Coordinates Will Change?
	; .Option_2_2
	; mov #8, b
	; mov #16, c
	; P_Draw_Sprite "" ""
	P_Draw_Sprite	option2_sprite_address, b, c
	P_Draw_Sprite	cursor_sprite_address, b, c
	P_Draw_Sprite	Confirm_Button_Sprite_Address, b, c ; Mov The "Highlighted" Or "Normal" Button To The Address.
	ret
















