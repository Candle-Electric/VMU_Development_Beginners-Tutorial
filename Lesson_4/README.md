# Lesson 4: Switching Scenes, Providing Menus, And Drawing Numbers

## Splitting Code Between Different Files, And Using `ret` To Cycle Between Them

Right now, our code is booting directly into its "Gameplay" State. However, when you play a Finished Retail Game, it starts up with a Main Menu before diving in, right? Let's learn how to do that in our VMU code!

We have our `main.asm`, which is the File we've been Building so far. Therein, we jump right into our "Gameplay" Loop. Now, we're going to switch `main.asm`'s `Main_Loop` to loop through the _other_ sections of our Code. In this Lesson, those two Sections will be a Main Menu, where we can change some Options before playing, and the Gameplay Loop that we've been coding up until now. `main.asm` will still contain all of the Application Preparation and Instantiation From Lesson 1; it's what's inside that `Main_Loop` that we'll be moving:

      Main_Loop:
         call Main_Menu
         call Cursor_Gameplay
         jmpf Main_Loop

We're going to move what used to be in `Main_Loop` to a New Code File, where we will be calling its Loop as seen above. Our Gameplay at the moment is akin to Dragging a Mouse Cursor around the Screen, so let's call it `Cursor_Gameplay`. `Main_Menu` is where we'll be coding our new, well, Main Menu! Let's move our old Main Loop to `Cursor_Gameplay` first. This should be as simple as Copy-Pasting it into a New File; just make sure to change the Function Name and `jmpf` at the end to Jump to `Cursor_Gameplay`, rather than `Main_Loop` as it was before:

<details>
  <summary>Cursor_Gameplay.asm</summary>

	;=======================;
	;    Cursor Gameplay    ;
	;=======================;
	
	Cursor_Gameplay:
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
		jmpf Cursor_Gameplay
</details>

Let's also move our Variable Declarations to our new `Cursor_Gameplay` File, while we're at it. Since the X-Position, Y-Position, and Sprite Addresses are only going to be used in this section of the code, we can pull them out from `main.asm` and declare them here. For variables that we want to remain consistent throughout each "Scene," however (E.G., which character is selected -- when the User goes back to the Menu, we want that character highlighted.), we'll declare them in `main.asm` and make sure not to assign other variables to the `$`-Addresses they occupy. Since setting these variables will happen outside of the Gameplay Loop (I.E. we don't want to initialize them every Frame.), let's rename `Cursor_Gameplay:` to `Cursor_Gameplay_Loop:`, and use `Cursor_Gameplay:` the way we use `start:` in `main.asm`. Let's make sure to change the `jmpf` to target `Cursor_Gameplay_Loop` accordingly, as well. It should look like this when you're done:

<details>
  <summary>Cursor_Gameplay.asm, with Variable Initialization and the Renamed Gameplay Loop</summary>

	;=======================;
	;    Cursor Gameplay    ;
	;=======================;

	Cursor_Gameplay:
		test_sprite_x			=		$6		; 1 Byte
		test_sprite_y			=		$7		; 1 Byte
		test_sprite_sprite_address	=		$8		; 2 Bytes

	; Set Sprite Addresses
		mov	#20, test_sprite_x
		mov	#12, test_sprite_y
		mov	#<Example_Sprite_Mask, test_sprite_sprite_address
		mov	#>Example_Sprite_Mask, test_sprite_sprite_address+1
 
	Cursor_Gameplay_Loop:
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
		jmpf Cursor_Gameplay_Loop
</details>

This way, we can use Addresses `$6`, `$7`, and `$8` in other Files. Think of them as "Local Variables" in this sense. Keeping every Declaration in `main.asm` has its benefits as well though, and we'll talk about that trade-off later in this lesson.

## Handling Menus

For menus, we're going to start off with a key distinction; namely, that between `Check_Button_Pressed` and `ld p3`. We've been using the latter, which will "hold" the button, as we've seen with our moving sprite onscreen. The former, however, just checks for the press, and returns once -- this will be perfect for menus! Otherwise, the cursor will flash rapidly when pressing the button for anything more than one frame. We're going to handle our menu with sprite images, in the same format we've been drawing them, as the text. In other words, we'll be drawing out our text as `.asm` sprites, and drawing them in our selection slots. I'll be honest, I don't know how to draw text from strings to the screen. It certainly is possible though, as seen in titles like Chao Adventure 2; it's just outside my capabilities!

Let's have two options on our selection screen. We know how to draw sprites and backgrounds, right? So, let's try having a "Character Select" and a "Stage Select," allowing the Player to choose the former and the latter. Before we code the menu, let's draw two more sprites and two more backgrounds.

Now that our New Graphics are ready, let's make a new scene for the menu, separate from our Gameplay Loop! we can switch between them by calling the `ret` Command when the requisite Loop is done. This will take us to the next "Scene" in the List we have in `main.asm`:

Since we have 3 characters and 3 stages to choose from, let's create the logic for those now. Speaking in Pseudo-Code, it will look something like this:

* Is the "Character" Row Selected?
    * Yes:
        * Is the Cursor on Character 1?
            * `P_Draw_Sprite Character_1_Highlighted
        * Is it Character 2?
            * `P_Draw_Sprite Character_2_Highlighted
        * Is it Character 3?
            * `P_Draw_Sprite Character_2_Highlighted
    * No:
        * Did the User choose Character 1?
            * `P_Draw_Sprite Character_1_Not_Highlighted
        * ...Or Character 2?
            * `P_Draw_Sprite Character_2_Not_Highlighted
        * ..._Or_ Character 3?
            * `P_Draw_Sprite Character_3_Not_Highlighted
* Is the "Stage" Row Selected?
    * Repeat the Above. ^
* Is The "Done" Button Row Selected?
    * Yes:
        * Draw Done_Button_Highlighted
    * No:
        * Draw Done_Button_Not_Highlighted  

To determine where the Cursor is and what is selected, we'll use Flags. We could use one "Flag" variable, using each Bit to represent an option, but since we have three characters and three stages to choose from, rather than a binary "On/Off" switch for these options, we'll give each its own Flag, in addition to one more for the Menu's Cursor:

      character_flag      =      $15 ; 1 Byte
      stage_flag          =      $16 ; 1 Byte
      cursor_flag         =      $17 ; 1 Byte

With our skeleton laid out, let's translate it into our Main Menu Assembly Code!

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
	.Handle_OK_Button_Text ; Note: May Change These To "Start" And "Resume," Depending On If The User Has Come From Boot-Up Or From "Pausing."
	.Draw_OK_Button_Highlighted
		ld Cursor_Flags
		sub #2
		bnz .Draw_OK_Button_Not_Highlighted
		mov #<OK_Button_Highlighted, ok_button_sprite_address
		mov #>OK_Button_Highlighted, ok_button_sprite_address+1
		jmpf .Draw_Screen
	.Draw_OK_Button_Not_Highlighted
		ld Cursor_Flags
		sub #2
		bz .Draw_Screen
		mov #<OK_Button, ok_button_sprite_address
		mov #>OK_Button, ok_button_sprite_address+1
	.Draw_Screen
    	...

   ## Drawing Digits

Although drawing alphabetic text is outside my skill level, I do know how to draw numbers on-the-fly from live values in memory. We can take our numbers, and calculate the Remainders of the Base-10 Digits to draw the Sprites accordingly.
