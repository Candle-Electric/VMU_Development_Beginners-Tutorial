;=======================;
;Beginners' VMU Tutorial;
;       Lesson 3        ;
;=======================;

;=======================;
;VMU Application Header ;
;=======================;
.include "GameHeader.i"

;=======================;
;   Include Libraries   ;
;=======================;
.include "./lib/libperspective.asm"
.include "./lib/libkcommon.asm"
.include "./lib/sfr.i"

;=======================;
;     Include Images    ;
;=======================;
.include		"./img/Hello_World_BackGround.asm"
.include		"./img/Example_Sprite.asm"
.include		"./img/Example_Sprite_Mask.asm"

;=======================;
;   Define Variables:   ;
;=======================;
p3_pressed			=		$4		; 1 Byte (For LibKCommon)
p3_last_input			=		$5		; 1 Byte (For LibKCommon)
test_sprite_x			=		$6		; 1 Byte
test_sprite_y			=		$7		; 1 Byte
test_sprite_sprite_address	=		$8		; 2 Bytes

;=======================;
;       Constants       ;
;=======================;
T_BTN_SLEEP				equ		7
T_BTN_MODE				equ		6
T_BTN_B1				equ		5
T_BTN_A1				equ		4
T_BTN_RIGHT1				equ		3
T_BTN_LEFT1				equ		2
T_BTN_DOWN1				equ		1
T_BTN_UP1				equ		0

;=======================;
;  Prepare Application  ;
;=======================;
	.org	$00
	jmpf	start

	.org	$03
	reti	

	.org	$0b
	reti	
	
	.org	$13
	reti	

	.org	$1b
	jmpf	t1int
	
	.org	$23
	reti	

	.org	$2b
	reti	
	
	.org	$33
	reti	

	.org	$3b
	reti	

	.org	$43
	reti	

	.org	$4b
	clr1	p3int,0
	clr1	p3int,1
	reti

	.org	$130	
t1int:
	push	ie
	clr1	ie,7
	not1	ext,0
	jmpf	t1int
	pop	ie
	reti

	.org	$1f0

goodbye:	
	not1	ext,0
	jmpf	goodbye

;=======================;
;     Main Program      ;
;=======================;
start:
	clr1 ie,7
	mov #$a1,ocr
	mov #$09,mcr
	mov #$80,vccr
	clr1 p3int,0
	clr1 p1,7
	mov #$ff,p3
	set1 ie,7
; Set Sprite Addresses
	mov	#20, test_sprite_x
	mov	#12, test_sprite_y
	mov	#<Example_Sprite_Mask, test_sprite_sprite_address
	mov	#>Example_Sprite_Mask, test_sprite_sprite_address+1

Main_Loop:
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
	jmpf Main_Loop

	.cnop	0,$200		; Pad To An Even Number Of Blocks
