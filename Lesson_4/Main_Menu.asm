;=======================;
;       Main Menu       ;
;=======================;

;=======================;
;   Define Variables:   ;
;=======================;
cursor_flags				= $6 ; 1 Byte
character_text_sprite_address		= $7 ; 2 Bytes
character_selection_sprite_address 	= $9 ; 2 Bytes
stage_text_sprite_address		= $11 ; 2 Bytes
stage_selection_sprite_sprite_address	= $13 ; 2 Bytes

;=======================;
; Initialize Variables  ;
;=======================;
mov #0, cursor_flags ; When The User "Pauses" To The Menu, We'll Always Put The Cursor On The Top Option. Character_Flags And Stage_Flags Will Be Inherited, As They're Already Set In Memory In Main.ASM Or In Cursor_Gameplay.ASM.

;=======================;
; Set Sprite Addresses  ;
;=======================;
; Character_Flag Will Already Be Set From Main.ASM When We Get Here, So We'll Need To Set This Before The Loop:
.Initialize_Character_1
	ld	character_flags
	bnz	.Intialize_Character_2
	mov	#<Character_Select_1_Highlighted, character_selection_sprite_address
	mov	#>Character_Select_1_Highlighted, character_selection_sprite_address+1
	jmpf 	.Initialize_Stage_1
.Initialize_Character_2
	ld	character_flags
	sub	#1
	bnz	.Intialize_Character_3
	mov	#<Character_Select_2_Highlighted, character_selection_sprite_address
	mov	#>Character_Select_2_Highlighted, character_selection_sprite_address+1
	jmpf 	.Initialize_Stage_1
.Initialize_Character_3
	ld	character_flags
	sub	#2
	bnz	.Intialize_Stage_1
	mov	#<Character_Select_3_Highlighted, character_selection_sprite_address
	mov	#>Character_Select_3_Highlighted, character_selection_sprite_address+1
.Initialize_Stage_1
	ld	stage_flags
	bnz	.Initialize_Stage_2
	mov	#<Stage_Select_1_Highlighted, stage_selection_sprite_address
	mov	#>Stage_Select_1_Highlighted, stage_selection_sprite_address+1
	jmpf	.Initialize_OK_Button
.Initialize_Stage_2
	ld	stage_flags
	sub	#1
	bnz	.Initialize_Stage_3
	mov	#<Stage_Select_2_Highlighted, stage_selection_sprite_address
	mov	#>Stage_Select_2_Highlighted, stage_selection_sprite_address+1
	jmpf	.Initialize_OK_Button
.Initialize_Stage_3
	ld	stage_flags
	sub	#2
	bnz	.Initialize_OK_Button
	mov	#<Stage_Select_3_Highlighted, stage_selection_sprite_address
	mov	#>Stage_Select_3_Highlighted, stage_selection_sprite_address+1
.Initialize_OK_Button
	mov	#<OK_Button_Not_Highlighted, ok_button_sprite_address
	mov	#>OK_Button_Not_Highlighted, ok_button_sprite_address+1

;=======================;
;       Main Loop       ;
;=======================;
Main_Menu:
; Check Input
.Check_Up
	callf Get_Input
	ld p3
	bp acc, T_BTN_UP1, .Check_Down
	inc cursor_flags
	jmpf .Handle_Cursor_Variables_Overflow
.Check_Down
	callf Get_Input
	ld p3
	bp acc, T_BTN_DOWN1, .Check_Left
	dec cursor_flags
	jmpf .Handle_Cursor_Variables_Overflow
.Check_Left
	callf Get_Input ; This Function Is In LibKCommon.ASM
	ld p3
	bp acc, T_BTN_LEFT1, .Check_Right
.Left_Character_Select
	ld cursor_flags
	bnz .Left_Stage_Select
	dec character_flags
	jmpf .Handle_Cursor_Variables_Overflow
.Left_Stage_Select
	ld cursor_flags
	sub #1
	bnz .Handle_Cursor_Variables_Overflow
	dec character_flags
	jmpf .Handle_Cursor_Variables_Overflow
.Check_Right
	callf Get_Input ; This Function Is In LibKCommon.ASM
	ld p3
	bp acc, T_BTN_RIGHT1, .Check_OK_Button
.Right_Character_Select
	ld cursor_flags
	bnz .Right_Stage_Select
	inc character_flags
	jmpf .Check_OK_Button
.Right_Stage_Select
	ld cursor_flags
	sub #1
	bnz .Handle_Cursor_Variables_Overflow
	inc character_flags
.Check_OK_Button
	ld cursor_flags
	sub #2
	bnz .Handle_Cursor_Variables_Overflow
	callf Get_Input ; Will Change This To Get_Button_Pressed Later, Noting In The Article For Users That It Records The Button Press Once.
	bn acc, T_BTN_A1, .Click_OK
	bn acc, T_BTN_B1, .Click_OK
	jmpf .Handle_Cursor_Variables_Overflow
.Click_OK
	ret
.Handle_Cursor_Variables_Overflow
.Check_Cursor_Overflow_Up
	ld cursor_flags
	sub #3
	bp acc, 7, .Check_Cursor_Overflow_Down
	mov #0, cursor_flags
	jmpf .Check_Character_Select_Overflow_Up
.Check_Cursor_Overflow_Down
	ld cursor_flags
	sub #1
	bn acc, 7, .Check_Character_Select_Overflow
	mov #3, cursor_flags
.Check_Character_Select_Overflow_Up
	ld character_flags
	sub #3
	bp acc, 7, .Check_Character_Select_Overflow_Down
	mov #0, character_flags
	jmpf .Check_Stage_Select_Overflow_Up
.Check_Character_Select_Overflow_Down
	ld character_flags
	sub #1
	bn acc, 7, .Check_Stage_Select_Overflow_Up
	mov #3, character_flags
.Check_Stage_Select_Overflow_Up
	ld stage_flags
	sub #3
	bp acc, 7, .Check_Stage_Select_Overflow_Down
	mov #0, stage_flags
	jmpf .Handle_Character_Selection_Text
.Check_Stage_Select_Overflow_Down
	ld stage_flags
	sub #1
	bn acc, 7, .Handle_Character_Selection_Text
	mov #3, stage_flags
.Handle_Character_Selection_Text
.Cursor_On_Character_Select
  bn  Cursor_Flags, 0, .Cursor_Not_On_Character_Select ; Load Flag -- Is It Selected? If So, Which Character?
.Handle_Character_Highlighted_Text
  ; P_Draw_Sprite ... ; Draw "Character:," Highlighted ; (We'll Switch It To "Player:" For Space.).
.Handle_Character_Not_Highlighted_Text
  ; P_Draw_Sprite
.Character_1_Highlighted
  ld Character_Flags
  sub #1
  bnz .Character_2_Highlighted
  mov #<Highlighted_1>, character_selection_sprite_address+1
  jmpf .Handle_Stage_Selection_Text
.Character_2_Highlighted
  ld Character_Flags
  sub #2
  bnz .Character_3_Highlighted
  mov #<Highlighted_2>, character_selection_sprite_address+1
  jmpf .Handle_Stage_Selection_Text
.Character_3_Highlighted
  ld Character_Flags
  sub #3
  bnz .Handle_Stage_Selection_Text ; Just In Case
  mov #<Highlighted_3>, character_selection_sprite_address+1
  jmpf .Handle_Stage_Selection_Text
.Cursor_Not_On_Character_Select  
.Character_1_Not_Highlighted
  ld Character_Flags
  sub #1
  bnz .Character_2_Not_Highlighted
  mov #<Not_Highlighted_1>, character_selection_sprite_address+1
  jmpf .Handle_Stage_Selection_text
.Character_2_Not_Highlighted
  ld Character_Flags
  sub #2
  bnz .Character_3_Not_Highlighted
  mov #<Not_Highlighted_2>, character_selection_sprite_address+1
  jmpf .Handle_Stage_Selection_text
.Character_3_Not_Highlighted
  ld Character_Flags
  sub #3
  bnz  .Handle_Stage_Selection_text
  mov #<Not_Highlighted_3>, character_selection_sprite_address+1
.Handle_Stage_Selection_Text
.Cursor_On_Stage_Select
  bn  Cursor_Flags, 1, .Cursor_Not_On_Stage_Select
.Stage_1_Highlighted
  ld Stage_Flags
  sub #1
  bnz .Stage_2_Highlighted
  mov #<Highlighted_1>, stage_selection_sprite_address+1
  jmpf .Draw_Screen
.Stage_2_Highlighted
  ld Stage_Flags
  sub #2
  bnz .Stage_3_Highlighted
  mov #<Highlighted_2>, stage_selection_sprite_address+1
  jmpf .Draw_Screen
.Stage_3_Highlighted
  ld Stage_Flags
  sub #3
  bnz .Draw_Screen ; Just In Case
  mov #<Highlighted_3>, stage_selection_sprite_address+1
  jmpf .Draw_Screen
.Cursor_Not_On_Stage_Select  
.Stage_1_Not_Highlighted
  ld Stage_Flags
  sub #1
  bnz .Stage_2_Not_Highlighted
  mov #<Not_Highlighted_1>, stage_selection_sprite_address+1
  jmpf .Draw_Screen
.Stage_2_Not_Highlighted
  ld Stage_Flags
  sub #2
  bnz .Stage_3_Not_Highlighted
  mov #<Not_Highlighted_2>, stage_selection_sprite_address+1
  jmpf .Draw_Screen
.Stage_3_Not_Highlighted
  ld Stage_Flags
  sub #3
  bnz  .Draw_Screen
  mov #<Not_Highlighted_3>, stage_selection_sprite_address+1
.Handle_OK_Button_Text
.Draw_OK_Button_Highlighted
	bn Cursor_Flags, 2, .Draw_OK_Button_Not_Highlighted
	mov #<Highlighted, ok_button_sprite_address+1
	jmpf .Draw_Screen
.Draw_OK_Button_Not_Highlighted
	bp Cursor_Flags, 2, .Draw_Screen
	mov #<Not_Highlighted, ok_button_sprite_address+1
.Draw_Screen
	P_Draw_Background_Constant Main_Menu_BackGround
	P_Draw_Sprite character_selection_sprite_address, #8, #8
	P_Draw_Sprite stage_selection_sprite_address, #16, #16
	P_Draw_Sprite ok_button_sprite_address, #8, #24
	P_Blit_Screen
	jmpf Main_Menu
