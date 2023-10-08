;=======================;
;       Main Menu       ;
;=======================;

;=======================;
;   Define Variables:   ;
;=======================;
cursor_flags				= $6 ; 1 Byte
character_selection_sprite_address 	= $7 ; 2 Bytes
stage_selection_sprite_sprite_address	= $9 ; 2 Bytes

;=======================;
; Set Sprite Addresses  ;
;=======================;
mov	#<Character_Select_1_Highlighted, character_selection_sprite_address
mov	#>Character_Select_1_Highlighted, character_selection_sprite_address+1

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
.Draw_Screen
	P_Draw_Background_Constant Main_Menu_BackGround
	P_Draw_Sprite character_selection_sprite_address, #8, #8
	P_Draw_Sprite stage_selection_sprite_address, #16, #16
	P_Blit_Screen
	jmpf Main_Menu
