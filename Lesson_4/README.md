# Lesson 4: Switching Scenes, Providing Menus, And Drawing Numbers

## Splitting Code Between Different Files, And Using `ret` To Cycle Between Them

Right now, our code is booting directly into its "Gameplay" State. However, when you play a Finished Retail Game, it starts up with a Main Menu before diving in, right? Let's learn how to do that in our VMU code!

We have our `main.asm`, which is the File we've been Building so far in WaterBear, and where we've been adding all of our Assembly Code. Therein, we define the "Start" Parameters of our Application and then jump right into our "Gameplay" Loop. Having everything all in one place can get overwhelming quickly, though. Now, we're going to split everything up into a few separate Assembly Files, and then switch `main.asm`'s `Main_Loop` to loop through the _other_ sections of our Code. In this Lesson, those two Sections will be a Main Menu, where we can change some Options before playing, and the Gameplay Loop that we've been coding up until now. `main.asm` will still contain all of the Application Preparation and Instantiation From Lesson 1; it's what's inside that `Main_Loop` that we'll be moving. Starting now, `Main_Loop` will simply be used to Loop through the other Assembly Code Files:

      Main_Loop:
         call Main_Menu
         call Cursor_Gameplay
         jmpf Main_Loop

We're going to move what _used_ to be in `Main_Loop` to a New Code File.  Our "Gameplay" at the moment is akin to Dragging a Mouse Cursor around the Screen, so let's name it `Cursor_Gameplay.asm`. Then, we can call it in `Main_Loop` as seen above. `Main_Menu` is where we'll be coding our new, well, Main Menu! Let's move our old Main Loop to `Cursor_Gameplay` first. This should be as simple as Copy-Pasting it into a New File; just make sure to change the Function Name and `jmpf` at the end to Jump to `Cursor_Gameplay`, rather than `Main_Loop` as it was before:

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

This way, we can use Addresses `$6`, `$7`, and `$8` in other Files. Think of them as "Local Variables" in this sense. Keeping every Declaration in `main.asm` has its benefits as well though, and we'll talk about that trade-off later in this lesson. Next, we'll learn how to switch between these code files that we've laid out in our `main.asm`. We'll be doing so with the `ret` Function. When `ret` is called inside one of our `.asm` Files, we'll move to the next one in our `main.asm` List. So, if we wanted to move out from `Cursor_Gameplay.asm` with the B Button, we'd do:

	Cursor_Gameplay_Loop:
		; Check Input
		callf Get_Input ; This Function Is In LibKCommon.ASM
		ld p3
	.Check_B
    		bp acc, T_BTN_B1, Check_Up
      		ret
	.Check_Up
  		...

So, if we don't press the B Button, we'll continue on with our `Cursor_Gameplay_Loop`, and if we do, we'll move on to the next call in our `Main_Loop`, which brings us back up to `Main_Menu`. Let's write up a new code file for `Main_Menu` next!

## Handling Menus
### Check_Button_Pressed

For menus, we're going to start off with a key distinction; namely, that between `Check_Button_Pressed` and `Get_Input`. We've been using the latter, which checks whether a button is "on" or "off" during the frame that it's called. This will reflect whether the user "holds" the button, as we've seen with our moving sprite onscreen -- when we hold a directional button, the sprite continues to move in that direction. The former, however, just checks for the press, and returns once -- this will be perfect for menus! Otherwise, the cursor will flash rapidly when pressing the button for anything more than one frame. For any normal user, that means the cursor would fly around the screen at the slightest press of a button. The syntax for `Check_Button_Pressed` is largely similar to that of `Get_Input`, specifiying a button and then providing a value that tells the code where to branch off to:

		callf	Get_Input
		mov 	#Button_B, acc
		callf 	Check_Button_Pressed
		bn 	acc, #Button_B, .we_did_not_press_b
	.we_pressed_b
 		; Do whatever the B button does!
	.we_did_not_press_b
 		; The user didn't press B...Go about your business as usual!

This time, we'll be providing the button in question to the `acc` register, using the very handy definitions provided to us by LibKCommon. 

<details>
  <summary>Button Definitions Via lib/libkcommon.asm:</summary>	
	
	; Nicer names for button masks
	Button_Up               equ     %00000001
	Button_Down             equ     %00000010
	Button_Left             equ     %00000100
	Button_Right            equ     %00001000
	Button_A                equ     %00010000
	Button_B                equ     %00100000
	Button_Mode             equ     %01000000
	Button_Sleep            equ     %10000000
 </details>

`Check_Button_Pressed` will then overwrite `acc` with a 0 or 1 in each of its 8 Bits, representing the 8 Buttons, and reflecting whether or not the button is depressed. We can think of this like a Boolean variable, and since it's already in `acc`, we can easily `bp` or `bn` with the requisite bit without sparing a single extra clock cycle. Looking at the code that Kresna wrote for this Function, we can get a nice glimpse into how it works. The `p3` register is complemented by `p3_pressed_last`, which stores which buttons were "On" during the last frame. A Bitwise "And" Call then determines which was pressed this frame, but not last frame, ensuring that held buttons are skipped over:

One important thing to note is that since `p3_pressed_last` is populated during the Get_Input call, we must make sure that we are only calling `Get_Input` once per frame, I.E. once per Loop (or `Main_Loop`, `Cursor_Gameplay_Loop`, Etc.). Otherwise, `p3_pressed_last` will be overwritten with the same button-press matrix twice in one frame, breaking the `Check_Button_Pressed` Function and effectively breaking every button. 

### Drawing The Menu Text

We're going to handle our menu with sprite images, in the same format we've been drawing them, as the text. In other words, we'll be storing our text as `.asm` sprites, and drawing them out in our selection slots. I'll be honest, I don't know how to draw text from strings to the screen. It certainly is possible though, as seen in titles like Chao Adventure 2; it's just outside my capabilities!

Let's have two options on our selection screen. We know how to draw sprites and backgrounds, right? So, let's try having a "Character Select" and a "Stage Select," allowing the Player to choose the former and the latter. Before we code the menu, let's draw two more sprites and two more backgrounds.

We can then draw up a "Header" Text for the top of the screen, and a "Go" Button at the bottom of the screen for when the User wants to confirm their choices and continue to the "Gameplay" Loop. Now that our New Graphics are ready, let's make a new "scene" in `Main_Menu.asm` for the menu, separate from our Gameplay Loop! we can switch between them by calling the `ret` Command when the requisite Loop is done. This will take us to the next "Scene" in the List we have in `main.asm`:

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

This way, we can increment our option flags using our newly-learned `Check_Button_Pressed` Function. With our skeleton laid out, let's translate it into our Main Menu Assembly Code! Let's say we have three rows of options on our menu; these would be represented by our `example_cursor_flag` being a value of 0, 1, or 2. This is how we'd check User Input for the second one on our list:

	.Check_Example_Option
 		ld example_cursor_flag
   		sub #1 ; Make sure we're on the second option
		bnz .Check_Another_Example_Option ; Get Outta Here if we're not
	.Check_Example_Option_Left
		mov #Button_Left, acc
  		callf Check_Button_Pressed ; Did the User Press The "Left" Button While on this Option?
		bnz .Check_Example_Option_Left ; If not, check if they Pressed "Right."
		dec example_option_flag ; If so, -1 to the Option's Flag!
	.Check_Example_Option_Right
 		mov #Button_Right, acc ; Do the same for the "Right Button Press" Side. 
   		callf Check_Button_Pressed
		bnz .Check_Another_Example_Option
		inc example_option_flag ; Since this time it's a Right Press, we'll +1 the Flag!
	.Check_Another_Example_Option ; Repeat the process for our next Row in the Cursor's List.
  		ld example_cursor_flag
		sub #2
		bnz .Check_Another_ANOTHER_Example_Option
	...

With that example under our belts, let's flesh it out with some additions by capturing some User Input and moving that Cursor to cycle through the "Characters" and "Stages" we'll be choosing from for our Example Code. With "Up" and "Down" Button Presses, we can simply Decrement and Increment our `cursor_flag` Variable, respectively. For Left and Right, we can do the same for our Option Variables, but we'll first need to check where our `cursor_flag` is so we know which one to edit.

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
