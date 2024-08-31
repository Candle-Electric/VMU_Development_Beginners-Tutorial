;=======================;
;       Main Menu       ;
;=======================;
Main_Menu:

;=======================;
;   Define Variables:   ;
;=======================;
cursor_flags				= $26 ; 1 Byte
character_text_sprite_address		= $7 ; 2 Bytes
character_selection_sprite_address 	= $9 ; 2 Bytes
stage_text_sprite_address		= $11 ; 2 Bytes
stage_selection_sprite_address	= $13 ; 2 Bytes
ok_button_sprite_address		= $15 ; 2 Bytes
;character_flags		=	$17 ; 1 Byte
;stage_flags		=	$18 ; 1 Byte
menu_heading_message_sprite_address = $19 ; 2 Bytes

;=======================;
; Initialize Variables  ;
;=======================;
mov #0, cursor_flags ; When The User "Pauses" To The Menu, We'll Always Put The Cursor On The Top Option. Character_Flags And Stage_Flags Will Be Inherited, As They're Already Set In Memory In Main.ASM Or In Cursor_Gameplay.ASM.
mov #0, character_flags
mov #0, stage_flags

;=======================;
; Set Sprite Addresses  ;
;=======================;
.Initialize_Welcome_Message
	mov #<Menu_Text_Welcome_Message, menu_heading_message_sprite_address
	mov #<Menu_Text_Welcome_Message, menu_heading_message_sprite_address+1
; Character_Flag Will Already Be Set From Main.ASM When We Get Here, So We'll Need To Set This Before The Loop:
.Initialize_Character_1
	ld	character_flags
	bnz	.Initialize_Character_2
	mov	#<Menu_Text_Character_1_Highlighted, character_selection_sprite_address
	mov	#>Menu_Text_Character_1_Highlighted, character_selection_sprite_address+1
	jmpf 	.Initialize_Stage_1
.Initialize_Character_2
	ld	character_flags
	sub	#1
	bnz	.Initialize_Character_3
	mov	#<Menu_Text_Character_2_Smiley_Highlighted, character_selection_sprite_address
	mov	#>Menu_Text_Character_2_Smiley_Highlighted, character_selection_sprite_address+1
	jmpf 	.Initialize_Stage_1
.Initialize_Character_3
	ld	character_flags
	sub	#2
	bnz	.Initialize_Stage_1
	mov	#<Menu_Text_Character_3_Highlighted, character_selection_sprite_address
	mov	#>Menu_Text_Character_3_Highlighted, character_selection_sprite_address+1
.Initialize_Stage_1
	ld	stage_flags
	bnz	.Initialize_Stage_2
	mov	#<Menu_Text_Stage_1_City_Highlighted, stage_selection_sprite_address
	; mov	#<Menu_Text_Character_1_Highlighted, stage_selection_sprite_address
	mov	#>Menu_Text_Stage_1_City_Highlighted, stage_selection_sprite_address+1
	; mov	#>Menu_Text_Character_1_Highlighted, stage_selection_sprite_address+1
	mov	#<Menu_Text_Character_1_Highlighted, stage_selection_sprite_address
	mov	#>Menu_Text_Character_1_Highlighted, stage_selection_sprite_address+1
	jmpf	.Initialize_OK_Button
.Initialize_Stage_2
	ld	stage_flags
	sub	#1
	bnz	.Initialize_Stage_3
	; mov	#<Menu_Text_Stage_2_Highlighted, stage_selection_sprite_address
	; mov	#>Menu_Text_Stage_2_Highlighted, stage_selection_sprite_address
	mov	#<Menu_Text_Character_2_Smiley_Highlighted, stage_selection_sprite_address
	mov	#>Menu_Text_Character_2_Smiley_Highlighted, stage_selection_sprite_address+1
	jmpf	.Initialize_OK_Button
.Initialize_Stage_3
	ld	stage_flags
	sub	#2
	bnz	.Initialize_OK_Button
	; mov	#<Menu_Text_Stage_3_Highlighted, stage_selection_sprite_address
	; mov	#>Menu_Text_Stage_3_Highlighted, stage_selection_sprite_address+1
	mov	#<Menu_Text_Character_3_Highlighted, stage_selection_sprite_address
	mov	#>Menu_Text_Character_3_Highlighted, stage_selection_sprite_address+1
.Initialize_OK_Button
	mov	#<Menu_Text_OK_Button_Start, ok_button_sprite_address
	mov	#>Menu_Text_OK_Button_Start, ok_button_sprite_address+1

;=======================;
;       Main Loop       ;
;=======================;
Main_Menu_Loop:
; Check Input
.Check_Up
	callf Get_Input ; Note To Self: Note To Users That you Only Wanna Call This Once Per Frame, For p3_Last_PRessed.
	mov #Button_Up, acc
	callf Check_Button_Pressed
	bn acc, 0, .Check_Down
	ld cursor_flags
	bz .Reset_Cursor_Overflow_Up
	dec cursor_flags
	jmpf .Handle_Character_Selection_Text
.Reset_Cursor_Overflow_Up
	mov #2, cursor_flags
	jmpf .Handle_Character_Selection_Text
.Check_Down
	mov #Button_Down, acc
	callf Check_Button_Pressed
	bn acc, 1, .Check_Left ; bnz .Check_Left
	ld cursor_flags
	sub #2
	bz .Reset_Cursor_Overflow_Down
	inc cursor_flags
	jmpf .Handle_Character_Selection_Text
.Reset_Cursor_Overflow_Down
	mov #0, cursor_flags
	jmpf .Handle_Character_Selection_Text
.Check_Left
	mov #Button_Left, acc
	callf Check_Button_Pressed
	bn acc, 2, .Check_Right ; bnz .Check_Right
.Left_Character_Select
	ld cursor_flags
	bnz .Left_Stage_Select
	ld character_flags
	bnz .decrement_character_flags
	mov #2, character_flags
	jmpf .Handle_Character_Selection_Text
.decrement_character_flags
	dec character_flags
	jmpf .Handle_Character_Selection_Text
.Left_Stage_Select
	ld cursor_flags
	sub #1
	bnz .Handle_Character_Selection_Text
	ld stage_flags
	bnz .decrement_stage_flags
	mov #2, stage_flags
	jmpf .Handle_Character_Selection_Text
.decrement_stage_flags
	dec stage_flags
	jmpf .Handle_Character_Selection_Text
.Check_Right
	mov #Button_Right, acc
	callf Check_Button_Pressed
	bn acc, 3, .Check_OK_Button ; bnz .Check_OK_Button
.Right_Character_Select
	ld cursor_flags
	bnz .Right_Stage_Select
	ld character_flags
	sub #2
	bnz .increment_character_flags
	mov #0, character_flags
	jmpf .Check_OK_Button
.increment_character_flags
	inc character_flags
	jmpf .Check_OK_Button
.Right_Stage_Select
	ld cursor_flags
	sub #1 ; #2
	bnz .Handle_Character_Selection_Text
	ld stage_flags
	sub #2
	bnz .increment_stage_flags
	mov #0, stage_flags
	jmpf .Check_OK_Button
.increment_stage_flags
	inc stage_flags
.Check_OK_Button
	ld cursor_flags
	sub #2
	;bnz .Handle_Character_Selection_Text
	
	; callf Get_Input ; Will Change This To Get_Button_Pressed Later, Noting In The Article For Users That It Records The Button Press Once.
	; bn acc, T_BTN_A1, .Click_OK
	; bn acc, T_BTN_B1, .Click_OK
	
	;mov #Button_A, acc
	;callf Check_Button_Pressed
	;bn acc, 4, .Click_OK ; bnz .Click_OK
	;mov #Button_B, acc
	;callf Check_Button_Pressed
	;bn acc, 5, .Click_OK ; bnz .Click_OK
	;jmpf .Handle_Character_Selection_Text
.Click_OK
	ret

	; callf Get_Input
	ld p3
	bn acc, T_BTN_A1, .Return_To_Menu
	bn acc, T_BTN_B1, .Return_To_Menu
	jmpf .Handle_Character_Selection_Text
	
	callf Check_Button_Pressed
	bn acc, 4, .Return_To_Menu
	bn acc, 5, .Return_To_Menu
	jmpf .Handle_Character_Selection_Text
.Return_To_Menu
	; mov #0, cursor_flags
	ret

.Handle_Character_Selection_Text
.Cursor_On_Character_Select
  ; bn  Cursor_Flags, 0, .Cursor_Not_On_Character_Select ; Load Flag -- Is It Selected? If So, Which Character?
  ld cursor_Flags
  bnz .Cursor_Not_On_Character_Select
.Handle_Character_Highlighted_Text
.Character_1_Highlighted
  ld Character_Flags
  bnz .Character_2_Highlighted
  mov #<Menu_Text_Character_1_Highlighted, character_selection_sprite_address
  mov #>Menu_Text_Character_1_Highlighted, character_selection_sprite_address+1
  jmpf .Handle_Stage_Selection_Text
.Character_2_Highlighted
  ld Character_Flags
  sub #1
  bnz .Character_3_Highlighted
  mov #<Menu_Text_Character_2_Smiley_Highlighted, character_selection_sprite_address
  mov #>Menu_Text_Character_2_Smiley_Highlighted, character_selection_sprite_address+1
  jmpf .Handle_Stage_Selection_Text
.Character_3_Highlighted
  ld Character_Flags
  sub #2
  bnz .Handle_Stage_Selection_Text ; Just In Case
  mov #<Menu_Text_Character_3_Highlighted, character_selection_sprite_address
  mov #>Menu_Text_Character_3_Highlighted, character_selection_sprite_address+1
  jmpf .Handle_Stage_Selection_Text
.Cursor_Not_On_Character_Select  
.Character_1_Not_Highlighted
  ld Character_Flags
  bnz .Character_2_Not_Highlighted
  mov #<Menu_Text_Character_1, character_selection_sprite_address
  mov #>Menu_Text_Character_1, character_selection_sprite_address+1
  jmpf .Handle_Stage_Selection_text
.Character_2_Not_Highlighted
  ld Character_Flags
  sub #1
  bnz .Character_3_Not_Highlighted
  mov #<Menu_Text_Character_2, character_selection_sprite_address
  mov #>Menu_Text_Character_2, character_selection_sprite_address+1
  jmpf .Handle_Stage_Selection_text
.Character_3_Not_Highlighted
  ld Character_Flags
  sub #2
  bnz  .Handle_Stage_Selection_text
  mov #<Menu_Text_Character_3, character_selection_sprite_address
  mov #>Menu_Text_Character_3, character_selection_sprite_address+1
.Handle_Stage_Selection_Text
.Cursor_On_Stage_Select
  ld cursor_Flags
  sub #1
  bnz .Cursor_Not_On_Stage_Select
.Stage_1_Highlighted
  ld Stage_Flags
  bnz .Stage_2_Highlighted
  ; mov #<Menu_Text_Stage_1_Highlighted, stage_selection_sprite_address
  ; mov #>Menu_Text_Stage_1_Highlighted, stage_selection_sprite_address+1
  mov #<Menu_Text_Character_1_Highlighted, stage_selection_sprite_address
  mov #>Menu_Text_Character_1_Highlighted, stage_selection_sprite_address+1
  jmpf .Draw_OK_Button_Highlighted
.Stage_2_Highlighted
  ld Stage_Flags
  sub #1
  bnz .Stage_3_Highlighted
  ; mov #<Menu_Text_Stage_2_Highlighted, stage_selection_sprite_address
  ; mov #>Menu_Text_Stage_2_Highlighted, stage_selection_sprite_address+1
  mov #<Menu_Text_Stage_2_Jungle_Highlighted, stage_selection_sprite_address
  mov #>Menu_Text_Stage_2_Jungle_Highlighted, stage_selection_sprite_address+1
  jmpf .Draw_OK_Button_Highlighted
.Stage_3_Highlighted
  ld Stage_Flags
  sub #2
  bnz .Draw_Screen ; Just In Case
  ; mov #<Menu_Text_Stage_3_Highlighted, stage_selection_sprite_address
  ; mov #>Menu_Text_Stage_3_Highlighted, stage_selection_sprite_address+1
  mov #<Menu_Text_Character_3_Highlighted, stage_selection_sprite_address
  mov #>Menu_Text_Character_3_Highlighted, stage_selection_sprite_address+1
  jmpf .Draw_OK_Button_Highlighted
.Cursor_Not_On_Stage_Select  
.Stage_1_Not_Highlighted
  ld Stage_Flags
  bnz .Stage_2_Not_Highlighted
  mov #<Menu_Text_Stage_1_City, stage_selection_sprite_address
  mov #>Menu_Text_Stage_1_City, stage_selection_sprite_address+1
  ; mov #<Menu_Text_Character_1, stage_selection_sprite_address
  ; mov #>Menu_Text_Character_1, stage_selection_sprite_address+1
  jmpf .Draw_OK_Button_Highlighted
.Stage_2_Not_Highlighted
  ld Stage_Flags
  sub #1
  bnz .Stage_3_Not_Highlighted
  mov #<Menu_Text_Stage_2_Jungle, stage_selection_sprite_address
  mov #>Menu_Text_Stage_2_Jungle, stage_selection_sprite_address+1
  jmpf .Draw_Screen
.Stage_3_Not_Highlighted
  ld Stage_Flags
  sub #2
  bnz  .Draw_OK_Button_Highlighted
   ;mov #<Menu_Text_Stage_3, stage_selection_sprite_address
   ;mov #>Menu_Text_Stage_3, stage_selection_sprite_address+1
  mov #<Menu_Text_Character_3, stage_selection_sprite_address
  mov #>Menu_Text_Character_3, stage_selection_sprite_address+1
.Handle_OK_Button_Text ; Note: May Change These To "Start" And "Resume," Depending On If The User Has Come From Boot-Up Or From "Pausing."
.Draw_OK_Button_Highlighted
	ld cursor_Flags
	sub #2
	bnz .Draw_OK_Button_Not_Highlighted
	mov #<Menu_Text_OK_Button_Start_Highlighted, ok_button_sprite_address
	mov #>Menu_Text_OK_Button_Start_Highlighted, ok_button_sprite_address+1
	jmpf .Draw_Screen
.Draw_OK_Button_Not_Highlighted
	ld cursor_Flags
	sub #2
	bz .Draw_Screen
	; mov #<Menu_Text_OK_Button_Resume, menu_heading_message_sprite_address
	; mov #>Menu_Text_OK_Button_Resume, menu_heading_message_sprite_address+1
	mov #<Menu_Text_OK_Button_Start, ok_button_sprite_address
	mov #>Menu_Text_OK_Button_Start, ok_button_sprite_address+1
	; mov	#<Menu_Text_Character_1_Highlighted, character_selection_sprite_address
	; mov	#>Menu_Text_Character_1_Highlighted, character_selection_sprite_address+1
	; mov	#<Menu_Text_Character_1, stage_selection_sprite_address
	; mov	#>Menu_Text_Character_1, stage_selection_sprite_address+1
.Draw_Screen
	mov #<Menu_Text_Welcome_Message, menu_heading_message_sprite_address ; ????????????? This Breaks Everything.
	mov #>Menu_Text_Welcome_Message, menu_heading_message_sprite_address+1
	P_Draw_Background_Constant Main_Menu_BG
	mov #0, b
	mov #0, c
	P_Draw_Sprite menu_heading_message_sprite_address, b, c
	mov #24, b
	mov #8, c
	P_Draw_Sprite character_selection_sprite_address, b, c ; #8, #8 ; Change to b,c
	mov #24, b
	;ld	b
	;add cursor_flags
	;st b
	mov #16, c
	P_Draw_Sprite stage_selection_sprite_address, b, c ; #16, #16
	mov #0, b
	mov #24, c
	P_Draw_Sprite ok_button_sprite_address, b, c ; #8, #24
	P_Blit_Screen
	jmpf Main_Menu_Loop
