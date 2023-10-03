;=======================;
;       Main Menu       ;
;=======================;

;=======================;
;   Define Variables:   ;
;=======================;
cursor_flags                              = $6 ; 1 Byte
character_selection_sprite_address 				= $7 ; 2 Bytes
stage_selection_sprite_sprite_address     = $9 ; 2 Bytes

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
  bn  Cursor_Flags, 0, .Cursor_Not_On_Character_Select ; Load Flag -- Is It Selected?
  mov #<Highlighted>, character_selection_sprite_address+1
  jmpf .Handle_Stage_Selection_Text
.Cursor_Not_On_Character_Select  
  mov #<Not_Highlighted>, character_selection_sprite_address+1
.Handle_Stage_Selection_Text
.Draw_Screen
	P_Draw_Background_Constant Main_Menu_BackGround
	P_Draw_Sprite character_selection_sprite_address, #8, #8
	P_Draw_Sprite stage_selection_sprite_address, #16, #16
	P_Blit_Screen
	jmpf Main_Menu
