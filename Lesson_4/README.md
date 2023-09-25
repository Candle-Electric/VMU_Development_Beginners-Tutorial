# Lesson 4: Switching Scenes, Providing Menus, And Drawing Numbers

Right now, our code is booting directly into its "Gameplay" State. However, when you play a Finished Retail Game, it starts up with a Main Menu before diving in, right? Let's learn how to do that in our VMU code!

For menus, we're going to start off with a key distinction; namely, that between `Check_Button_Pressed` and `ld p3`. We've been using the latter, which will "hold" the button, as we've seen with our moving sprite onscreen. The former, however, just checks for the press, and returns once -- this will be perfect for menus! Otherwise, the cursor will flash rapidly when pressing the button for anything more than one frame. 
