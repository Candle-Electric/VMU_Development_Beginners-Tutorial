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
	callf Get_Input ; This Function Is In LibKCommon.ASM
	ld p3
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
