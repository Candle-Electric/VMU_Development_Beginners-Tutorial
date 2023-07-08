Lesson 2

Now that we have learned how to draw an Image to the Full Screen, we can start to draw smaller Sprites as well! To do so, we will call on LibPerspective once again. The Syntax to Draw A Sprite is as follows:

  P_Draw_Sprite	sprite_address, sprite_x_coordinate, sprite_y_coordinate

The X-Coordinate and Y-Coordinate determine where onscreen our Sprite will be drawn. The Sprite Address is an assigned section of Memory that contains the Data for Image itself. We will head back to the "Start" Section of our Code, before the Main Loop, and assign the Memory Addresses for all three of these:
  
  ;=======================;
  ;   Define Variables:   ;
  ;=======================;
  ...
  test_sprite_x			=		$6		; 1 Byte
  test_sprite_y			=		$7		; 1 Byte
  test_sprite_sprite_address	=	$8		; 2 Bytes

Now that we have allocated where in Memory these will be, let's assign the actual Numbers and Image to them:

  ; Set Sprite Addresses
  mov	#20, test_sprite_x
	mov	#12, test_sprite_y
	mov	#<Example_Sprite, test_sprite_sprite_address
	mov	#>Example_Sprite, test_sprite_sprite_address+1

Note that we have four variables here; the "<" and ">" for the Sprite Address are the two halves of the Image. The X- and Y-Coordinates count to the right and downward as the numbers increase:

*Image*
X--->|
     |
     V
     Y
     
So, we're ready to Draw our Sprite!

  .Draw_Screen
     P_Draw_Background_Constant Hello_World_BackGround
	   P_Draw_Sprite	test_sprite_sprite_address, test_sprite_x, test_sprite_y
	   P_Blit_Screen

Depending on which X/Y Coordinates you used, the Sprite may look a little funky, or cut off. We'll discuss why that is in a bit. Next, we'll learn how to Capture User Input and Move our Sprite!
