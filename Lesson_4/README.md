# Lesson 4: Switching Scenes, Providing Menus, And Drawing Numbers

Right now, our code is booting directly into its "Gameplay" State. However, when you play a Finished Retail Game, it starts up with a Main Menu before diving in, right? Let's learn how to do that in our VMU code!

We have our `main.asm`, which is the File we've been Building so far. Therein, we jump right into our "Gameplay" Loop. Now, we're going to switch `main.asm`'s `Main_Loop` to loop through the _other_ sections of our Code. In this Lesson, those two Sections will be a Main Menu, where we can change some Options before playing, and the Gameplay Loop that we've been coding up until now. `main.asm` will still contain all of the Application Preparation and Instantiation From Lesson 1; it's what's inside that `Main_Loop` that we'll be moving:

      Main_Loop:
         call Main_Menu
         call Cursor_Gameplay
         jmpf Main_Loop

We're going to move what used to be in `Main_Loop` to a New Code File, where we will be calling its Loop as seen above. Our Gameplay at the moment is akin to Dragging a Mouse Cursor around the Screen, so let's call it `Cursor_Gameplay`. `Main_Menu` is where we'll be coding our new, well, Main Menu!

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

With our skeleton laid out, let's translate it into our Main Menu Assembly Code!

    .draw_character_selection
    .draw_character_1_selected
    bn .selection_flags, 0, .draw_character_2_selected
    .draw_character_2_selected
    ...

Although drawing text is outside my skill level, I do know how to draw numbers on-the-fly from live numbers in memory.
