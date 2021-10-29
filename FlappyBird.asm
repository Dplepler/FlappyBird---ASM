IDEAL
MODEL small
STACK 100h
DATASEG
	
	x dw 120
	y dw 100

	playerSizeX dw 0

	playerSizeY dw 0

	color db 14
	background db 11  ;Color
	tubeColour db 10
	
	velocity dw 1

	velocityJump dw 7

	keystroke db ?

	rJump db 0 ;Remember jump so later on we will make the flappy bird indeed jump

	Clock EQU es:6Ch

	loseMessage db 'You lost :(', '$'

	tubeY dw 0
	tubeX dw 239
	tubeYmax dw 50
	tube2Ymax dw 50

	tubeSizeY dw 0
	tubeSizeX dw 0

	rememberTube db 0 ;Variable to remember if already drawn second tube

	lost db 0
	checkIfLost db 1

CODESEG

proc flappyBird


	mov ah, 6h
	xor al, al
	xor cx, cx  
	mov dx, 184Fh 			;setting a cyan background
	mov bh, [background]
	int 10h
	
	
	
gameLoop:
	
	
input:

	mov al, 0
	mov ah, 1h ;input
	int 16h
	jnz keyPressed
	xor dl, dl
	jmp printPlayer


keyPressed:
	mov ah, 0
	int 16h 	;input
	mov dl, al
	
	cmp dl, ' ' ;If space key is pressed
	je rememberJump
	jmp print

rememberJump:
	mov [rJump], 1
	jmp print


	
randomNum:           ;this is for the random Y size of the tubes 
	mov ax, 40h
	mov es, ax
	mov ax, [Clock]    
	and al, 00000111b  ;random num between 0 - 7
	mov cl, al
	mov ax, 10
	mul cl
	
	cmp ax, 0 ;If the random number is equal to 0 I want to load another random number
	je randomNum
	
	mov [tubeYmax], ax ;load random number between 0 - 70
	
	mov [tubeSizeX], 0 ;Reset values of the tubes for the same reason
	mov [tubeSizeY], 0
	
	mov [tubeX], 295 ;Tube will now be drawn in the beginning
	mov [tubeY], 0 
	
	jmp printPlayer
	
	

print:

	mov dx, [tubeX]
	add dx, [tubeSizeX]
	cmp dx, 0 ;if tube has passed the screen create new one with a random size
	jl randomNum

	
printPlayer:

	cmp [playerSizeX], 15 ;Checking if it finished drawing a row (15 is the width of the player)
	je incY
	
	mov bh, 0
	mov cx, [x]
	add cx, [playerSizeX]
	mov dx, [y]
	add dx, [playerSizeY]
	mov al, [color]
	mov ah,0Ch
	int 10h
	
	inc [playerSizeX]
	jmp print
	
incY:	;All of this prints a 15x10 player
	
	
	cmp [playerSizeY], 10
	je tube
	
	
	add [playerSizeY], 1
	mov [playerSizeX], 0
	
	
	jmp printPlayer
	
	
tube:


	
	cmp [tubeSizeX], 25 ;X will equal 25
	je incYtube

	mov bh, 0
	mov cx, [tubeX]
	add cx, [tubeSizeX]
	mov dx, [tubeY]
	add dx, [tubeSizeY]
	mov al, [tubeColour]
	mov ah,0Ch
	int 10h
	
	inc [tubeSizeX]
	jmp tube
	
incYtube:


	mov dx, [tubeYmax]
	cmp [tubeSizeY], dx  ;compare to max
	je resetValues
	
	
	add [tubeSizeY], 1
	mov [tubeSizeX], 0
	
	
	jmp tube
	
tube2:

	cmp [tubeSizeX], 25 ;X will equal 25
	je incYtube2

	mov bh, 0
	mov cx, [tubeX]
	add cx, [tubeSizeX]
	mov dx, [tubeY]
	add dx, [tubeSizeY]
	mov al, [tubeColour]
	mov ah,0Ch
	int 10h
	
	inc [tubeSizeX]
	jmp tube2
	
incYtube2:

	mov [rememberTube], 1 ;Telling the program I already drew tube 2

	mov dx, [tube2Ymax]
	cmp [tubeSizeY], dx  ;compare to max
	je resetValues
	
	
	add [tubeSizeY], 1
	mov [tubeSizeX], 0
	
	
	jmp tube2
	

changeTubeY:

	mov dx, [tubeSizeY]
	mov [tubeY], dx
	add [tubeY], 75 ;Adding to the Y
	
	mov ax, 200 ;Moving screen Y size to ax
	sub ax, [tubeSizeY] ;Now ax equals the amount needed to draw to reach the end of the screen for tube 2
	sub ax, 75

	mov [tube2Ymax], ax ;And now tube2Ymax equals that too
	
	
	mov [tubeSizeX], 0 ;Reset values 
	mov [tubeSizeY], 0

	jmp tube2

resetValues:


	mov [playerSizeX], 0 ;Reset so the program will draw them again at different locations
	mov [playerSizeY], 0
	
	cmp [rememberTube], 0
	je changeTubeY  ;If didn't draw tube 2 yet, draw tube 2
	
	mov [tubeSizeX], 0 ;Reset values 
	mov [tubeSizeY], 0
	
	mov [tubeY], 0 ;Reset value
	
	mov [rememberTube], 0 ;Reset 
	
	mov ax, 40h
	mov es, ax
	mov ax, [Clock]
	mov cx, 1
	
DelayLoop:                 ;This is delay so that we will see how the bird falls down
	mov ax, [Clock]

Tick:
	cmp ax, [Clock]
	je Tick
	loop DelayLoop
	jmp deleteFlappyFrame
	

loseCheckpoint: ;Checkpoint to lose when collision is detected
	
	mov [velocity], 0
	
	jmp lose

	
checkIfLostLabel:

	mov bh, 0
	mov cx, [x] ;left up corner
	mov dx, [y]	;read pixel color
	mov ah, 0Dh
	int 10h

	cmp al, [tubeColour] ;Before deleting tube or flappy bird, check if there's collision
	je loseCheckpoint
	
	

	mov bh, 0
	mov cx, [x] ;right up corner
	add cx, [playerSizeX]
	mov dx, [y]	;read pixel color
	mov ah, 0Dh
	int 10h
	
	cmp al, [tubeColour] ;Before deleting tube or flappy bird, check if there's collision
	je loseCheckpoint
	
	
	mov bh, 0
	mov cx, [x] ;left down corner
	mov dx, [y]	;read pixel color
	add dx, [playerSizeY]
	mov ah, 0Dh
	int 10h
	
	cmp al, [tubeColour] ;Before deleting tube or flappy bird, check if there's collision
	je loseCheckpoint
	
	mov bh, 0
	mov cx, [x] ;right down corner
	add cx, [playerSizeX]
	mov dx, [y]	;read pixel color
	add dx, [playerSizeY]
	mov ah, 0Dh
	int 10h
	
	cmp al, [tubeColour] ;Before deleting tube or flappy bird, check if there's collision
	je loseCheckpoint
	
	jmp deleteFlappy
	
deleteFlappyFrame: ;This label deletes last FlappyBird and tube from screen before drawing new one


	cmp [checkIfLost], 1 ;If label is turned on, we haven't lost yet, if turned off, we have
	je checkIfLostLabel
	
deleteFlappy:	

	cmp [playerSizeX], 15 ;checking if it finished drawing a row (15 is the width of the player)
	je incYdelete
	
	
	mov bh, 0
	mov cx, [x]
	add cx, [playerSizeX]
	mov dx, [y]
	add dx, [playerSizeY]
	mov al, [background]
	mov ah,0Ch
	int 10h
	
	inc [playerSizeX]
	jmp deleteFlappyFrame
	
incYdelete:
	
	cmp [playerSizeY], 10
	je deleteTube
	
	add [playerSizeY], 1
	mov [playerSizeX], 0
	
	
	jmp deleteFlappyFrame
	
	
loseCheckpoint2:
	jmp lose 
	
deleteTube:

	cmp [lost], 1 ;if lost is turned on, go back to the label
	je loseCheckpoint2

	cmp [tubeSizeX], 25 ;X will equal 25
	je incYtubeDelete

	mov bh, 0
	mov cx, [tubeX]
	add cx, [tubeSizeX]
	mov dx, [tubeSizeY]
	mov al, [background]
	mov ah,0Ch
	int 10h
	
	inc [tubeSizeX]
	jmp deleteTube
	

incYtubeDelete:

	mov dx, 200
	cmp [tubeSizeY], dx  ;compare to max
	je moveTube
	
	
	add [tubeSizeY], 1
	mov [tubeSizeX], 0
	
	
	jmp deleteTube

	
	
	
checkpoint:
	
	mov [velocityJump], 7  ;reseting values to be ready for next jump
	mov [rJump], 0
	
	mov [velocity], 1 ;reseting velocity to get ready for new fall
	
	jmp gameLoop ;This is to fix a bug that when trying to jump from the Jump label to gameloop it's out of range.
	


moveTube:

	mov [tubeSizeX], 0 ;Reset values of the tubes for the same reason
	mov [tubeSizeY], 0
	
	sub [tubeX], 5
	jmp gravity
	

jump:


	mov [playerSizeX], 0 ;Reset so the program will draw them again at different locations
	mov [playerSizeY], 0
	
	xor ax, ax
	xor bx, bx
	mov bx, [velocityJump]
	mov ax, 2
	mul bx
	sub [y], ax
	
	sub [velocityJump], 1
	
	cmp [y], 0 ;if Y equals 0 or lower, flappy bird flew to close to the sun 
	jl lose
	
	
	cmp [velocityJump], 0 ;jump loop
	je checkpoint
	jmp print
	
	
gravity:
	
	mov [playerSizeX], 0 ;Reset so the program will draw them again at different locations
	mov [playerSizeY], 0
	
	cmp [rJump], 1
	je jump
	
	xor ax, ax
	xor bx, bx
	mov bx, [velocity] ;Acceleration equals 1 so no need to multiply velocity
	add [y], bx
	
	inc [velocity]
	
	cmp [y], 190 ;if Y equals 190 or higher, flappy bird has fallen down and died :(
	jg lose
	
	
	jmp gameLoop

lose:

	mov [lost], 1 
	mov [checkIfLost], 0 ;Setting boolean to false 

	cmp [y], 190
	jg lostMessage
	
	mov dx, [velocity]
	add [y], dx
	inc [velocity]
	
	mov [playerSizeX], 0 ;Reset so the program will draw them again at different locations
	mov [playerSizeY], 0
	
	
	jmp printPlayer

lostMessage:
	mov ah, 2
	mov bh, 0
	mov dx, 0C10h
	int 10h

	mov ah, 9
	lea dx, [loseMessage]
	int 21h
	
	ret
	

endp flappyBird

	
start:
	mov ax, @data
	mov ds, ax
	
	;Switching to Video Graphic Array
	mov ax, 13h
	int 10h
	
	
	;;;;;;;;;;;;;;;;code
	call flappyBird
	
	
exit:
	;Wait for key
	xor ax, ax
	mov ah, 1h
	int 21h
	
	mov dl,'A' ; print 'A'
	mov ah,2
	int 21h
	
	
	mov ax, 4c00h
	int 21h
END start


