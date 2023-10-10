;=======================;
;Beginners' VMU Tutorial;
;       Lesson 4        ;
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
;  Include  Code Files  ;
;=======================;
.include		"./Cursor_Gameplay.asm"
.include		"./Main_Menu.asm"

;=======================;
;   Define Variables:   ;
;=======================;
p3_pressed					=		$4		; 1 Byte (For LibKCommon)
p3_last_input				=		$5		; 1 Byte (For LibKCommon)
test_sprite_x				=		$6		; 1 Byte
test_sprite_y				=		$7		; 1 Byte
test_sprite_sprite_address	=		$8		; 2 Bytes

;=======================;
;       Constants       ;
;=======================;
T_BTN_SLEEP				equ		7
T_BTN_MODE				equ		6
T_BTN_B1				equ		5
T_BTN_A1				equ		4
T_BTN_RIGHT1			equ		3
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

Main_Loop:
	callf	Main_Menu
	callf	Cursor_Gameplay
	jmpf Main_Loop

	.cnop	0,$200		; Pad To An Even Number Of Blocks
