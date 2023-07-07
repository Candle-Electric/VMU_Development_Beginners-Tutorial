## Lesson 1: Getting Started

Hello, and welcome to the VMU Beginner's Development Tutorial!

To start, you'll need these 3 things:

- WaterBear: 	This Assembler is awesome.
- LibPerspective:	I don't know how to draw to the screen without it.
- ElysianVMU: This is the best VMU Emulator out there, and has handy tools for Developers.

Once you've got those three installed, we're going to start by drawing a static image to the screen. Let's create and compile our first VMU Program!
(main.asm)

Create main.asm in your text editor of choice; you can use anything you'd like. I'll be using Visual Studio. You can do "touch main.asm" in Git Bash if your Text Editor doesn't allow you to make an .asm File. You'll need these lines of code for every VMU Application, so paste them in to begin:

  	;=======================;
	;  Prepare Application	;
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

	;nop_irq:
	;reti

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


We can discuss what these do later; for now you don't need to worry about what they do under the hood. To be honest, I still don't know what a lot of them do! 

Now, we want to `.include` the LibPerspective  Library to our Program. You can do this by pasting the Library into your Directory: And then using .include to add its Binary in main.asm:

Now that we have everything ready, we can write our first bit of code! To start, we will do something analogous to "Hello World." Well, sort of. Writing text to the Screen is not as easy on the VMU as it is on other platforms. Lots of Games write text and scroll it, but to be honest with you I don't know how to do that. But, with LibPerspective, drawing to the screen is easy as pie! Specifically, we will be using the `P_Draw_Background_Constant` Macro to draw an image to the full screen. All we need to do is draw out the text that we want to write, as a Bitmap in Assembly. You can do this in your Text Editor. I like to CTRL+F for 1 and then hit the Insert Key and draw. 

The Format that Libperspective expects is is a 6-By-32 Array of 8-Byte (1-Bit) Words, matching the 48-By-32 Resolution of the VMU's Screen. So, now that we have our Bitmap, we can add it to our program with .include, like we did before. This way, Libperspective will be able to access the data to draw it. P_Draw_Yes_OK

Now that our code is ready, let's use WaterBear to build it! Running it, you can now see the image that you drew!
